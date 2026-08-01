import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/repositories/collection_repository.dart';
import '../../database/repositories/player_repository.dart';
import '../../database/repositories/save_repository.dart';
import '../../database/schema.dart';
import '../../engine/engine.dart';
import '../app_config.dart';
import 'database_providers.dart';

/// Reads scripts out of the asset bundle.
final Provider<StoryLoader> storyLoaderProvider = Provider<StoryLoader>(
  (ref) => StoryLoader(
    resolver: (String path) =>
        rootBundle.loadString('${AppConfig.storyRoot}$path'),
  ),
);

/// Command table. Register plugin handlers here and every episode gets them.
final Provider<CommandRegistry> commandRegistryProvider =
    Provider<CommandRegistry>((ref) => createCommandRegistry());

/// Immutable view of the running story that widgets watch.
class GameSession {
  const GameSession({
    this.status = RuntimeStatus.idle,
    this.state,
    this.choice,
    this.revision = 0,
    this.busy = false,
    this.episodeId = '',
    this.episodeTitle = '',
    this.error,
    this.diagnostics = const <String>[],
  });

  final RuntimeStatus status;

  /// The live aggregate. It mutates in place; [revision] is what changes.
  final GameState? state;
  final PendingChoice? choice;
  final int revision;
  final bool busy;
  final String episodeId;
  final String episodeTitle;
  final String? error;
  final List<String> diagnostics;

  bool get isLoaded => state != null;

  bool get isPlaying => status.isBusy || status.isBlocked;

  bool get isFinished => status == RuntimeStatus.finished;

  bool get waitingForChoice =>
      status == RuntimeStatus.awaitingChoice && choice != null;

  GameSession copyWith({
    RuntimeStatus? status,
    GameState? state,
    Object? choice = _sentinel,
    int? revision,
    bool? busy,
    String? episodeId,
    String? episodeTitle,
    Object? error = _sentinel,
    List<String>? diagnostics,
  }) => GameSession(
    status: status ?? this.status,
    state: state ?? this.state,
    choice: identical(choice, _sentinel)
        ? this.choice
        : choice as PendingChoice?,
    revision: revision ?? this.revision,
    busy: busy ?? this.busy,
    episodeId: episodeId ?? this.episodeId,
    episodeTitle: episodeTitle ?? this.episodeTitle,
    error: identical(error, _sentinel) ? this.error : error as String?,
    diagnostics: diagnostics ?? this.diagnostics,
  );

  static const Object _sentinel = Object();
}

/// Owns the [StoryRuntime] and bridges it to Riverpod.
///
/// Division of labour:
///  * the **runtime** executes the DSL and mutates [GameState];
///  * this controller republishes runtime signals as immutable [GameSession]
///    snapshots and mirrors persistent data into Drift;
///  * widgets never touch the runtime directly except through these methods.
class GameSessionController extends Notifier<GameSession> {
  StoryRuntime? _runtime;
  GameState? _state;
  Program? _program;

  final StreamController<EngineEffect> _effects =
      StreamController<EngineEffect>.broadcast();

  StreamSubscription<GameStateChange>? _stateSub;
  StreamSubscription<RuntimeStatus>? _statusSub;
  StreamSubscription<PendingChoice?>? _choiceSub;
  StreamSubscription<EngineEffect>? _effectSub;

  Timer? _saveDebounce;
  DateTime? _sessionStartedAt;
  Duration _accumulatedPlaytime = Duration.zero;

  /// One-shot presentation instructions (sound, toast, navigation…).
  Stream<EngineEffect> get effects => _effects.stream;

  StoryRuntime? get runtime => _runtime;

  @override
  GameSession build() {
    ref.onDispose(_teardown);
    return const GameSession();
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────

  /// Starts [episodeId] from the beginning, wiping the autosave slot.
  Future<void> newGame({
    String episodeId = AppConfig.defaultEpisodeId,
    int slot = AppSchema.autoSlot,
  }) async {
    state = state.copyWith(busy: true, error: null);
    try {
      final CompiledStory story = await _compile(episodeId);
      await ref.read(saveRepositoryProvider).deleteSlot(slot);

      final GameState fresh = await _freshState();
      _attach(fresh, story);

      await ref
          .read(collectionRepositoryProvider)
          .markEpisodeStarted(
            episodeId,
            number: story.episodeNumber,
            title: story.title,
          );

      _accumulatedPlaytime = Duration.zero;
      _sessionStartedAt = DateTime.now();
      await _runtime!.start(story.program);
      await _persist(force: true);
    } catch (error, stack) {
      _fail('Could not start $episodeId: $error', stack);
    }
  }

  /// Resumes the autosave, restoring the exact instruction the player left on.
  Future<bool> continueGame({int slot = AppSchema.autoSlot}) async {
    state = state.copyWith(busy: true, error: null);
    try {
      final SaveRepository saves = ref.read(saveRepositoryProvider);
      final EngineSnapshot? snapshot = await saves.readSnapshot(slot);
      if (snapshot == null) {
        state = state.copyWith(busy: false);
        return false;
      }

      final CompiledStory story = await _compile(
        snapshot.episodeId.isEmpty
            ? AppConfig.defaultEpisodeId
            : snapshot.episodeId,
      );

      final GameState restored = await _freshState(applyDefaults: false);
      _attach(restored, story);

      final SaveSlotSummary? summary = await saves.slot(slot);
      _accumulatedPlaytime = summary?.playtime ?? Duration.zero;
      _sessionStartedAt = DateTime.now();

      await _runtime!.restore(snapshot, story.program);
      return true;
    } catch (error, stack) {
      _fail('Could not load the save: $error', stack);
      return false;
    }
  }

  /// Compiles a script without running it — used by the debug/lint screen.
  Future<CompiledStory> compileOnly(String episodeId) => _compile(episodeId);

  Future<CompiledStory> _compile(String episodeId) async {
    final EpisodeManifest manifest = AppConfig.episode(episodeId);
    final CompiledStory story = await ref
        .read(storyLoaderProvider)
        .load(manifest.script, id: manifest.id);
    return story;
  }

  void _attach(GameState gameState, CompiledStory story) {
    _teardownRuntime();

    _state = gameState;
    _program = story.program;

    final StoryRuntime runtime = StoryRuntime(
      registry: ref.read(commandRegistryProvider),
      state: gameState,
      settings: _settings,
      onCheckpoint: (String? name) => _persist(force: true, name: name ?? ''),
    );
    _runtime = runtime;

    _stateSub = gameState.changes.listen(_onStateChange);
    _statusSub = runtime.statusChanges.listen(_onStatus);
    _choiceSub = runtime.choiceChanges.listen(_onChoice);
    _effectSub = runtime.effects.listen(_onEffect);

    state = state.copyWith(
      state: gameState,
      status: RuntimeStatus.running,
      choice: null,
      busy: false,
      revision: gameState.revision,
      episodeId: story.program.id,
      episodeTitle: story.title,
      error: null,
      diagnostics: story.diagnostics
          .map((Diagnostic d) => d.toString())
          .toList(growable: false),
    );
  }

  EngineSettings _settings = const EngineSettings();

  /// Applies new playback settings to a running episode immediately.
  void applySettings(EngineSettings settings) {
    _settings = settings;
    _runtime?.settings = settings;
    state = state.copyWith(revision: state.revision + 1);
  }

  EngineSettings get settings => _settings;

  /// Builds the starting world: profile, wallet and a phone with the
  /// pre-installed apps. Everything else comes from the script.
  Future<GameState> _freshState({bool applyDefaults = true}) async {
    final PlayerRepository players = ref.read(playerRepositoryProvider);
    final PlayerProfile profile = await players.loadProfile();
    final Wallet wallet = await players.loadWallet();
    _settings = await players.loadSettings();

    final GameState gameState = GameState(profile: profile, wallet: wallet);

    if (applyDefaults) {
      final DateTime now = DateTime.now();
      for (final String appId in EngineDefaults.preinstalledApps) {
        gameState.installApp(
          InstalledApp(
            id: appId,
            name: _appName(appId),
            icon: 'assets/icons/app_$appId.png',
            installedAt: now,
            system: true,
          ),
        );
      }
      gameState.updateProfile((PlayerProfile p) => p);
    }
    return gameState;
  }

  static String _appName(String id) {
    switch (id) {
      case 'messenger':
        return 'Messenger';
      case 'browser':
        return 'Orbit';
      case 'gallery':
        return 'Gallery';
      case 'contacts':
        return 'Contacts';
      case 'calls':
        return 'Phone';
      case 'settings':
        return 'Settings';
      case 'store':
        return 'Crystals';
      case 'makelove':
        return 'Makelove';
      default:
        return id;
    }
  }

  // ── Player input ────────────────────────────────────────────────────────

  Future<bool> select(int index) async {
    final StoryRuntime? runtime = _runtime;
    if (runtime == null) return false;
    final bool accepted = await runtime.select(index);
    if (accepted) await _persist();
    return accepted;
  }

  Future<void> skipWait() => _runtime?.skipWait() ?? Future<void>.value();

  void pause() => _runtime?.pause();

  Future<void> resume() => _runtime?.resume() ?? Future<void>.value();

  /// Writes the autosave right now (used when the app is backgrounded).
  Future<void> saveNow({int slot = AppSchema.autoSlot, String name = ''}) =>
      _persist(force: true, slot: slot, name: name);

  /// Copies the autosave into a manual slot.
  Future<void> saveToSlot(int slot, {String name = ''}) async {
    await _persist(force: true);
    await ref
        .read(saveRepositoryProvider)
        .copySlot(AppSchema.autoSlot, slot, name: name);
  }

  Future<bool> loadSlot(int slot) async {
    await ref.read(saveRepositoryProvider).copySlot(slot, AppSchema.autoSlot);
    return continueGame();
  }

  /// Credits crystals bought with real money (called by the billing layer).
  Future<void> creditCrystals(int amount, {String? sku}) async {
    final GameState? gameState = _state;
    if (gameState == null) {
      final PlayerRepository players = ref.read(playerRepositoryProvider);
      final Wallet wallet = await players.loadWallet();
      await players.saveWallet(wallet.credit(amount, sku: sku));
      return;
    }
    gameState.updateWallet((Wallet w) => w.credit(amount, sku: sku));
    await _persistWallet();
  }

  Future<void> grantEntitlement(String sku) async {
    final GameState? gameState = _state;
    if (gameState == null) {
      final PlayerRepository players = ref.read(playerRepositoryProvider);
      final Wallet wallet = await players.loadWallet();
      await players.saveWallet(wallet.grantEntitlement(sku));
      return;
    }
    gameState.updateWallet((Wallet w) => w.grantEntitlement(sku));
    await _persistWallet();
  }

  /// Opens an app from the home screen (a UI action, not a story action).
  void openApp(String appId, {String? threadId}) {
    final GameState? gameState = _state;
    if (gameState == null) return;
    if (threadId != null) {
      gameState.activeThreadId = threadId;
      gameState.markThreadRead(threadId);
    }
    gameState.updatePhone(
      (PhoneState p) => p.copyWith(currentApp: appId, locked: false),
    );
  }

  void closeApp() {
    _state?.updatePhone(
      (PhoneState p) => p.copyWith(currentApp: null, currentScreen: null),
    );
  }

  void openThread(String threadId) {
    final GameState? gameState = _state;
    if (gameState == null) return;
    gameState.activeThreadId = threadId;
    gameState.markThreadRead(threadId);
    gameState.notifySlice(GameStateSlice.threads, id: threadId);
  }

  /// Player-driven browsing. Mirrors what `@browser_visit` does so a page the
  /// player found by tapping behaves exactly like one the script opened.
  void browse(String rawUrl) {
    final GameState? gameState = _state;
    if (gameState == null) return;

    final String url = _canonicalUrl(rawUrl);
    final DateTime now = DateTime.now();

    gameState.updateBrowser((BrowserState b) {
      final List<BrowserTab> tabs = List<BrowserTab>.of(b.tabs);
      final String tabId = b.activeTabId ?? 'tab_${now.millisecondsSinceEpoch}';
      final int index = tabs.indexWhere((BrowserTab t) => t.id == tabId);
      final BrowserTab tab = BrowserTab(id: tabId, url: url, title: url);
      if (index >= 0) {
        tabs[index] = tab;
      } else {
        tabs.add(tab);
      }
      return b.copyWith(
        tabs: tabs,
        activeTabId: tabId,
        open: true,
        history: <BrowserHistoryEntry>[
          BrowserHistoryEntry(url: url, title: url, visitedAt: now),
          ...b.history,
        ].take(120).toList(),
      );
    });
    gameState.recordVisit(url);
    emitUiEvent(
      EngineEvents.browserVisited,
      data: <String, Object?>{'url': url},
    );
  }

  void selectTab(String tabId) {
    _state?.updateBrowser((BrowserState b) => b.copyWith(activeTabId: tabId));
  }

  /// `makelove.app` → `https://makelove.app`, search terms → the search engine.
  static String _canonicalUrl(String input) {
    final String value = input.trim();
    if (value.contains('://')) return value;
    final bool looksLikeDomain = RegExp(
      r'^[\w.-]+\.[a-z]{2,}(/.*)?$',
      caseSensitive: false,
    ).hasMatch(value);
    if (looksLikeDomain) return 'https://$value';
    return 'https://q-search.com/?q=${Uri.encodeComponent(value)}';
  }

  /// Lets the UI answer an `@await` in the script.
  ///
  /// This is how player-driven moments (tapping *Install* in the browser,
  /// answering a call, closing an app) hand control back to the story without
  /// any of that logic living in Dart.
  void emitUiEvent(
    String name, {
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    _runtime?.events.emit(EngineEvent(name, data: data, source: 'ui'));
  }

  void dismissPopup() {
    _state?.updateBrowser((BrowserState b) => b.copyWith(popup: null));
  }

  void dismissNotification(String id) {
    final GameState? gameState = _state;
    if (gameState == null) return;
    gameState.updatePhone(
      (PhoneState p) => p.copyWith(
        notifications: p.notifications
            .map(
              (GameNotification n) => n.id == id ? n.copyWith(read: true) : n,
            )
            .toList(),
      ),
    );
  }

  // ── Runtime signals ─────────────────────────────────────────────────────

  void _onStateChange(GameStateChange change) {
    state = state.copyWith(revision: change.revision);
    switch (change.slice) {
      case GameStateSlice.wallet:
        unawaited(_persistWallet());
        break;
      case GameStateSlice.gallery:
        unawaited(_persistGallery());
        break;
      case GameStateSlice.achievements:
        unawaited(_persistAchievements());
        break;
      default:
        _scheduleSave();
    }
  }

  void _onStatus(RuntimeStatus status) {
    state = state.copyWith(status: status);
    if (status == RuntimeStatus.awaitingChoice) {
      unawaited(_persist(force: true));
    }
    if (status == RuntimeStatus.finished) {
      unawaited(_onEpisodeFinished());
    }
  }

  void _onChoice(PendingChoice? choice) {
    state = state.copyWith(choice: choice);
  }

  void _onEffect(EngineEffect effect) {
    if (!_effects.isClosed) _effects.add(effect);
    if (effect is AchievementEffect) unawaited(_persistAchievements());
    if (effect is GalleryEffect) unawaited(_persistGallery());
  }

  Future<void> _onEpisodeFinished() async {
    final GameState? gameState = _state;
    if (gameState == null) return;
    await ref
        .read(collectionRepositoryProvider)
        .markEpisodeCompleted(
          gameState.episodeId,
          _runtime?.currentLabel ?? '',
        );
    await _persist(force: true);
  }

  // ── Persistence ─────────────────────────────────────────────────────────

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(seconds: 4), () => _persist());
  }

  Duration get _playtime {
    final DateTime? started = _sessionStartedAt;
    if (started == null) return _accumulatedPlaytime;
    return _accumulatedPlaytime + DateTime.now().difference(started);
  }

  Future<void> _persist({
    bool force = false,
    int slot = AppSchema.autoSlot,
    String name = '',
  }) async {
    final StoryRuntime? runtime = _runtime;
    final GameState? gameState = _state;
    if (runtime == null || gameState == null || _program == null) return;

    _saveDebounce?.cancel();
    try {
      final EngineSnapshot snapshot = runtime.snapshot();
      await ref
          .read(saveRepositoryProvider)
          .write(
            slot: slot,
            snapshot: snapshot,
            state: gameState,
            name: name,
            summary: _summaryFor(gameState),
            episodeNo: _program!.metaInt('episode', 0),
            playtime: _playtime,
            auto: slot == AppSchema.autoSlot,
          );
      await _persistWallet();
    } catch (error) {
      // Saving must never crash the story.
      if (!_effects.isClosed) {
        _effects.add(DebugEffect('Autosave failed: $error', level: 'error'));
      }
    }
  }

  String _summaryFor(GameState gameState) {
    final ChatThread? thread = gameState.activeThreadId == null
        ? null
        : gameState.thread(gameState.activeThreadId!);
    final ChatMessage? last = thread?.lastMessage;
    if (last != null && last.text.isNotEmpty) {
      return last.text.length > 90
          ? '${last.text.substring(0, 87)}…'
          : last.text;
    }
    return gameState.currentScene;
  }

  Future<void> _persistWallet() async {
    final GameState? gameState = _state;
    if (gameState == null) return;
    await ref
        .read(playerRepositoryProvider)
        .saveWallet(gameState.wallet, episodeId: gameState.episodeId);
  }

  Future<void> _persistGallery() async {
    final GameState? gameState = _state;
    if (gameState == null) return;
    final CollectionRepository collections = ref.read(
      collectionRepositoryProvider,
    );
    for (final GalleryUnlock item in gameState.gallery.values) {
      await collections.unlockGallery(item);
    }
  }

  Future<void> _persistAchievements() async {
    final GameState? gameState = _state;
    if (gameState == null) return;
    final CollectionRepository collections = ref.read(
      collectionRepositoryProvider,
    );
    for (final Achievement achievement in gameState.achievements.values) {
      await collections.saveAchievement(achievement);
    }
  }

  // ── Teardown ────────────────────────────────────────────────────────────

  void _fail(String message, [StackTrace? stack]) {
    state = state.copyWith(busy: false, error: message);
    if (!_effects.isClosed) {
      _effects.add(DebugEffect(message, level: 'error'));
    }
  }

  void _teardownRuntime() {
    _saveDebounce?.cancel();
    _stateSub?.cancel();
    _statusSub?.cancel();
    _choiceSub?.cancel();
    _effectSub?.cancel();
    _runtime?.dispose();
    _state?.dispose();
    _runtime = null;
    _state = null;
  }

  void _teardown() {
    _teardownRuntime();
    _effects.close();
  }
}

final NotifierProvider<GameSessionController, GameSession> gameSessionProvider =
    NotifierProvider<GameSessionController, GameSession>(
      GameSessionController.new,
    );

/// Stream of one-shot engine effects for the shell to react to.
final StreamProvider<EngineEffect> engineEffectProvider =
    StreamProvider<EngineEffect>(
      (ref) => ref.watch(gameSessionProvider.notifier).effects,
    );
