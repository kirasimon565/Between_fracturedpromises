import 'dart:async';

import '../variables/engine_value.dart';
import '../variables/variable_store.dart';
import 'browser.dart';
import 'chat.dart';
import 'phone.dart';
import 'progress.dart';
import 'relationships.dart';
import 'wallet.dart';

/// Which slice of the world changed — the Riverpod layer uses this to decide
/// what to rebuild.
enum GameStateSlice {
  variables,
  flags,
  relationships,
  characters,
  threads,
  phone,
  browser,
  inventory,
  evidence,
  journal,
  objectives,
  achievements,
  gallery,
  wallet,
  profile,
  scene,
  everything,
}

class GameStateChange {
  const GameStateChange(this.slice, this.revision, {this.id});

  final GameStateSlice slice;
  final int revision;
  final String? id;
}

/// The single mutable aggregate that represents "the world".
///
/// Every field is an immutable value (or a list/map that is replaced instead of
/// mutated), so UI code can hold on to a reference and compare identities.
class GameState {
  GameState({
    VariableStore? variables,
    PlayerProfile? profile,
    Wallet? wallet,
    PhoneState? phone,
    BrowserState? browser,
  }) : variables = variables ?? VariableStore(),
       _profile = profile ?? const PlayerProfile(),
       _wallet = wallet ?? const Wallet(),
       _phone = phone ?? const PhoneState(),
       _browser = browser ?? const BrowserState();

  final VariableStore variables;

  final Set<String> _flags = <String>{};
  final Map<String, Relationship> _relationships = <String, Relationship>{};
  final Map<String, CharacterState> _characters = <String, CharacterState>{};
  final Map<String, ChatThread> _threads = <String, ChatThread>{};
  final Map<String, InventoryItem> _inventory = <String, InventoryItem>{};
  final Map<String, EvidenceEntry> _evidence = <String, EvidenceEntry>{};
  final List<JournalEntry> _journal = <JournalEntry>[];
  final Map<String, Objective> _objectives = <String, Objective>{};
  final Map<String, Achievement> _achievements = <String, Achievement>{};
  final Map<String, GalleryUnlock> _gallery = <String, GalleryUnlock>{};
  final Set<String> _seenLabels = <String>{};
  final Set<String> _pickedChoices = <String>{};
  final Set<String> _visitedUrls = <String>{};

  PlayerProfile _profile;
  Wallet _wallet;
  PhoneState _phone;
  BrowserState _browser;

  String episodeId = '';
  String currentScene = '';
  String currentLabel = '';
  String? background;
  String? musicTrack;
  double musicVolume = 0.6;
  String? activeThreadId;
  String theme = 'safe';

  int _revision = 0;

  final StreamController<GameStateChange> _changes =
      StreamController<GameStateChange>.broadcast();

  Stream<GameStateChange> get changes => _changes.stream;

  int get revision => _revision;

  void dispose() {
    _changes.close();
  }

  void _touch(GameStateSlice slice, {String? id}) {
    _revision++;
    if (!_changes.isClosed) {
      _changes.add(GameStateChange(slice, _revision, id: id));
    }
  }

  // ── Flags ───────────────────────────────────────────────────────────────

  Set<String> get flags => Set<String>.unmodifiable(_flags);

  bool hasFlag(String name) => _flags.contains(name.trim().toLowerCase());

  void setFlag(String name, {bool value = true}) {
    final String key = name.trim().toLowerCase();
    final bool changed = value ? _flags.add(key) : _flags.remove(key);
    if (changed) _touch(GameStateSlice.flags, id: key);
  }

  void toggleFlag(String name) => setFlag(name, value: !hasFlag(name));

  // ── Relationships ───────────────────────────────────────────────────────

  Map<String, Relationship> get relationships =>
      Map<String, Relationship>.unmodifiable(_relationships);

  Relationship relationship(String characterId) =>
      _relationships[characterId.toLowerCase()] ??
      Relationship(characterId: characterId.toLowerCase());

  void setRelationship(Relationship relationship) {
    _relationships[relationship.characterId.toLowerCase()] = relationship;
    _touch(GameStateSlice.relationships, id: relationship.characterId);
  }

  num adjustRelationship(
    String characterId,
    RelationshipAxis axis,
    num delta, {
    bool absolute = false,
    num min = Relationship.min,
    num max = Relationship.max,
  }) {
    final Relationship current = relationship(characterId);
    final num next = absolute ? delta : current.axis(axis) + delta;
    final num clamped = next < min ? min : (next > max ? max : next);
    setRelationship(current.withAxis(axis, clamped));
    // Mirror into variables so scripts can read `trust_daniel` directly.
    variables.set('${axis.name}_${characterId.toLowerCase()}', clamped);
    return clamped;
  }

  // ── Characters ──────────────────────────────────────────────────────────

  Map<String, CharacterState> get characters =>
      Map<String, CharacterState>.unmodifiable(_characters);

  CharacterState? character(String id) => _characters[id.toLowerCase()];

  CharacterState ensureCharacter(String id, {String? name}) {
    final String key = id.toLowerCase();
    final CharacterState? existing = _characters[key];
    if (existing != null) return existing;
    final CharacterState created = CharacterState(
      id: key,
      name: name ?? _titleCase(key),
    );
    _characters[key] = created;
    _touch(GameStateSlice.characters, id: key);
    return created;
  }

  void updateCharacter(String id, CharacterState Function(CharacterState) fn) {
    final CharacterState current = ensureCharacter(id);
    _characters[id.toLowerCase()] = fn(current);
    _touch(GameStateSlice.characters, id: id.toLowerCase());
  }

  // ── Threads & messages ──────────────────────────────────────────────────

  Map<String, ChatThread> get threads =>
      Map<String, ChatThread>.unmodifiable(_threads);

  List<ChatThread> threadsForApp(String app) =>
      _threads.values
          .where((ChatThread t) => t.app == app && !t.archived)
          .toList()
        ..sort((ChatThread a, ChatThread b) {
          if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
          final DateTime at =
              a.lastActivity ?? DateTime.fromMillisecondsSinceEpoch(0);
          final DateTime bt =
              b.lastActivity ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bt.compareTo(at);
        });

  ChatThread? thread(String id) => _threads[id];

  ChatThread ensureThread(
    String id, {
    required String app,
    String? title,
    List<String>? participants,
    String? avatar,
  }) {
    final ChatThread? existing = _threads[id];
    if (existing != null) return existing;
    final ChatThread created = ChatThread(
      id: id,
      app: app,
      title: title ?? _titleCase(id),
      participants: participants ?? <String>[id],
      avatar: avatar,
      lastActivity: DateTime.now(),
    );
    _threads[id] = created;
    _touch(GameStateSlice.threads, id: id);
    return created;
  }

  void updateThread(String id, ChatThread Function(ChatThread) fn) {
    final ChatThread? current = _threads[id];
    if (current == null) return;
    _threads[id] = fn(current);
    _touch(GameStateSlice.threads, id: id);
  }

  void appendMessage(ChatMessage message) {
    final ChatThread thread = ensureThread(message.threadId, app: 'messenger');
    final bool active = activeThreadId == thread.id;
    _threads[thread.id] = thread.copyWith(
      messages: <ChatMessage>[...thread.messages, message],
      unread: message.isPlayer || active ? thread.unread : thread.unread + 1,
      lastActivity: message.timestamp,
      typingBy: null,
    );
    _touch(GameStateSlice.threads, id: thread.id);
  }

  void setTyping(String threadId, String? characterId) {
    final ChatThread? thread = _threads[threadId];
    if (thread == null) return;
    _threads[threadId] = thread.copyWith(typingBy: characterId);
    _touch(GameStateSlice.threads, id: threadId);
  }

  void markThreadRead(String threadId) {
    final ChatThread? thread = _threads[threadId];
    if (thread == null || thread.unread == 0) return;
    _threads[threadId] = thread.copyWith(unread: 0);
    _touch(GameStateSlice.threads, id: threadId);
  }

  // ── Phone ───────────────────────────────────────────────────────────────

  PhoneState get phone => _phone;

  void updatePhone(PhoneState Function(PhoneState) fn) {
    _phone = fn(_phone);
    _touch(GameStateSlice.phone);
  }

  void installApp(InstalledApp app) {
    if (_phone.hasApp(app.id)) return;
    updatePhone(
      (PhoneState p) => p.copyWith(apps: <InstalledApp>[...p.apps, app]),
    );
  }

  void uninstallApp(String id) {
    updatePhone(
      (PhoneState p) => p.copyWith(
        apps: p.apps
            .where((InstalledApp a) => a.id != id.toLowerCase() || a.system)
            .toList(),
      ),
    );
  }

  void pushNotification(GameNotification notification) {
    updatePhone(
      (PhoneState p) => p.copyWith(
        notifications: <GameNotification>[notification, ...p.notifications],
      ),
    );
  }

  void clearNotifications({String? appId}) {
    updatePhone(
      (PhoneState p) => p.copyWith(
        notifications: appId == null
            ? const <GameNotification>[]
            : p.notifications
                  .where((GameNotification n) => n.appId != appId)
                  .toList(),
      ),
    );
  }

  // ── Browser ─────────────────────────────────────────────────────────────

  BrowserState get browser => _browser;

  void updateBrowser(BrowserState Function(BrowserState) fn) {
    _browser = fn(_browser);
    _touch(GameStateSlice.browser);
  }

  bool hasVisited(String url) => _visitedUrls.contains(url.toLowerCase());

  void recordVisit(String url) {
    _visitedUrls.add(url.toLowerCase());
  }

  // ── Inventory / evidence / journal / objectives ─────────────────────────

  Map<String, InventoryItem> get inventory =>
      Map<String, InventoryItem>.unmodifiable(_inventory);

  bool hasItem(String id) => _inventory.containsKey(id.toLowerCase());

  void addItem(InventoryItem item) {
    final String key = item.id.toLowerCase();
    final InventoryItem? existing = _inventory[key];
    _inventory[key] = existing == null
        ? item
        : existing.copyWith(count: existing.count + item.count);
    _touch(GameStateSlice.inventory, id: key);
  }

  void removeItem(String id, {int count = 1}) {
    final String key = id.toLowerCase();
    final InventoryItem? existing = _inventory[key];
    if (existing == null) return;
    if (existing.count <= count) {
      _inventory.remove(key);
    } else {
      _inventory[key] = existing.copyWith(count: existing.count - count);
    }
    _touch(GameStateSlice.inventory, id: key);
  }

  Map<String, EvidenceEntry> get evidence =>
      Map<String, EvidenceEntry>.unmodifiable(_evidence);

  bool hasEvidence(String id) => _evidence.containsKey(id.toLowerCase());

  void addEvidence(EvidenceEntry entry) {
    _evidence[entry.id.toLowerCase()] = entry;
    _touch(GameStateSlice.evidence, id: entry.id);
  }

  void linkEvidence(String a, String b) {
    final EvidenceEntry? left = _evidence[a.toLowerCase()];
    if (left == null) return;
    if (left.linkedTo.contains(b.toLowerCase())) return;
    _evidence[a.toLowerCase()] = left.copyWith(
      linkedTo: <String>[...left.linkedTo, b.toLowerCase()],
    );
    _touch(GameStateSlice.evidence, id: a);
  }

  List<JournalEntry> get journal => List<JournalEntry>.unmodifiable(_journal);

  void addJournalEntry(JournalEntry entry) {
    final int index = _journal.indexWhere((JournalEntry e) => e.id == entry.id);
    if (index >= 0) {
      _journal[index] = entry;
    } else {
      _journal.add(entry);
    }
    _touch(GameStateSlice.journal, id: entry.id);
  }

  void updateJournalEntry(String id, String body) {
    final int index = _journal.indexWhere((JournalEntry e) => e.id == id);
    if (index < 0) return;
    _journal[index] = _journal[index].copyWith(body: body);
    _touch(GameStateSlice.journal, id: id);
  }

  Map<String, Objective> get objectives =>
      Map<String, Objective>.unmodifiable(_objectives);

  bool hasObjective(String id) => _objectives.containsKey(id.toLowerCase());

  void addObjective(Objective objective) {
    _objectives[objective.id.toLowerCase()] = objective;
    _touch(GameStateSlice.objectives, id: objective.id);
  }

  void setObjectiveStatus(String id, ObjectiveStatus status) {
    final Objective? objective = _objectives[id.toLowerCase()];
    if (objective == null) return;
    _objectives[id.toLowerCase()] = objective.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    _touch(GameStateSlice.objectives, id: id);
  }

  Map<String, Achievement> get achievements =>
      Map<String, Achievement>.unmodifiable(_achievements);

  bool hasAchievement(String id) =>
      _achievements[id.toLowerCase()]?.unlocked ?? false;

  void putAchievement(Achievement achievement) {
    _achievements[achievement.id.toLowerCase()] = achievement;
    _touch(GameStateSlice.achievements, id: achievement.id);
  }

  Map<String, GalleryUnlock> get gallery =>
      Map<String, GalleryUnlock>.unmodifiable(_gallery);

  bool hasGallery(String id) => _gallery.containsKey(id.toLowerCase());

  void unlockGallery(GalleryUnlock item) {
    _gallery[item.id.toLowerCase()] = item;
    _touch(GameStateSlice.gallery, id: item.id);
  }

  // ── Wallet & profile ────────────────────────────────────────────────────

  Wallet get wallet => _wallet;

  void updateWallet(Wallet Function(Wallet) fn) {
    _wallet = fn(_wallet);
    variables.set('crystals', _wallet.crystals);
    _touch(GameStateSlice.wallet);
  }

  PlayerProfile get profile => _profile;

  void updateProfile(PlayerProfile Function(PlayerProfile) fn) {
    _profile = fn(_profile);
    variables.set('player_name', _profile.name);
    variables.set('player_display_name', _profile.displayName);
    _touch(GameStateSlice.profile);
  }

  // ── Scene bookkeeping ───────────────────────────────────────────────────

  Set<String> get seenLabels => Set<String>.unmodifiable(_seenLabels);

  bool hasSeen(String label) => _seenLabels.contains(label);

  void markSeen(String label) {
    if (_seenLabels.add(label)) {
      _touch(GameStateSlice.scene, id: label);
    }
  }

  Set<String> get pickedChoices => Set<String>.unmodifiable(_pickedChoices);

  bool hasPicked(String id) => _pickedChoices.contains(id);

  void markPicked(String id) {
    _pickedChoices.add(id);
  }

  void setScene({
    String? scene,
    String? background,
    String? theme,
    String? label,
  }) {
    if (scene != null) currentScene = scene;
    if (background != null) this.background = background;
    if (theme != null) this.theme = theme;
    if (label != null) currentLabel = label;
    _touch(GameStateSlice.scene, id: scene);
  }

  void notifySlice(GameStateSlice slice, {String? id}) => _touch(slice, id: id);

  // ── Built-in lookups used by expressions ────────────────────────────────

  EngineValue lookup(String rawName) {
    final String name = rawName.trim().toLowerCase();

    if (variables.has(name)) return variables.get(name);

    switch (name) {
      case 'crystals':
        return EngineValue.number(_wallet.crystals);
      case 'player_name':
        return EngineValue.string(_profile.name);
      case 'player_display_name':
        return EngineValue.string(_profile.displayName);
      case 'pronouns':
        return EngineValue.string(_profile.pronouns);
      case 'episode':
        return EngineValue.string(episodeId);
      case 'scene':
        return EngineValue.string(currentScene);
      case 'label':
        return EngineValue.string(currentLabel);
      case 'battery':
      case 'phone.battery':
        return EngineValue.number(_phone.battery);
      case 'signal':
        return EngineValue.number(_phone.signal);
      case 'clock':
      case 'time':
        return EngineValue.string(_phone.clock);
      case 'date':
        return EngineValue.string(_phone.date);
      case 'location':
        return EngineValue.string(_phone.location);
      case 'weather':
        return EngineValue.string(_phone.weather);
      case 'network':
        return EngineValue.string(_phone.networkState);
      case 'theme':
        return EngineValue.string(theme);
      case 'current_app':
        return EngineValue.string(_phone.currentApp ?? '');
      case 'browser_url':
        return EngineValue.string(_browser.currentUrl);
      case 'unread':
        return EngineValue.number(_phone.unreadNotifications);
      case 'inventory_count':
        return EngineValue.number(_inventory.length);
      case 'evidence_count':
        return EngineValue.number(_evidence.length);
      case 'gallery_count':
        return EngineValue.number(_gallery.length);
      case 'achievement_count':
        return EngineValue.number(
          _achievements.values.where((Achievement a) => a.unlocked).length,
        );
    }

    // `trust_daniel`, `love_ethan`, … resolve against the relationship map.
    final int underscore = name.indexOf('_');
    if (underscore > 0) {
      final RelationshipAxis? axis = relationshipAxisFromName(
        name.substring(0, underscore),
      );
      if (axis != null) {
        final String character = name.substring(underscore + 1);
        if (_relationships.containsKey(character)) {
          return EngineValue.number(relationship(character).axis(axis));
        }
      }
    }

    if (_flags.contains(name)) return EngineValue.trueValue;

    return EngineValue.nullValue;
  }

  // ── Serialisation ───────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => <String, dynamic>{
    'variables': variables.toJson(),
    'flags': _flags.toList(),
    'relationships': _relationships.values
        .map((Relationship r) => r.toJson())
        .toList(),
    'characters': _characters.values
        .map((CharacterState c) => c.toJson())
        .toList(),
    'threads': _threads.values.map((ChatThread t) => t.toJson()).toList(),
    'phone': _phone.toJson(),
    'browser': _browser.toJson(),
    'inventory': _inventory.values
        .map((InventoryItem i) => i.toJson())
        .toList(),
    'evidence': _evidence.values.map((EvidenceEntry e) => e.toJson()).toList(),
    'journal': _journal.map((JournalEntry j) => j.toJson()).toList(),
    'objectives': _objectives.values.map((Objective o) => o.toJson()).toList(),
    'achievements': _achievements.values
        .map((Achievement a) => a.toJson())
        .toList(),
    'gallery': _gallery.values.map((GalleryUnlock g) => g.toJson()).toList(),
    'wallet': _wallet.toJson(),
    'profile': _profile.toJson(),
    'seen': _seenLabels.toList(),
    'picked': _pickedChoices.toList(),
    'visited': _visitedUrls.toList(),
    'episodeId': episodeId,
    'scene': currentScene,
    'label': currentLabel,
    if (background != null) 'background': background,
    if (musicTrack != null) 'music': musicTrack,
    'musicVolume': musicVolume,
    if (activeThreadId != null) 'activeThread': activeThreadId,
    'theme': theme,
  };

  void restore(Map<String, dynamic> json) {
    variables.restore(
      Map<String, Object?>.from(
        (json['variables'] as Map?) ?? const <String, Object?>{},
      ),
    );

    _flags
      ..clear()
      ..addAll(
        (json['flags'] as List<dynamic>? ?? const <dynamic>[]).map(
          (dynamic e) => e.toString(),
        ),
      );

    _relationships
      ..clear()
      ..addEntries(
        (json['relationships'] as List<dynamic>? ?? const <dynamic>[]).map((
          dynamic e,
        ) {
          final Relationship r = Relationship.fromJson(
            Map<String, dynamic>.from(e as Map),
          );
          return MapEntry<String, Relationship>(r.characterId, r);
        }),
      );

    _characters
      ..clear()
      ..addEntries(
        (json['characters'] as List<dynamic>? ?? const <dynamic>[]).map((
          dynamic e,
        ) {
          final CharacterState c = CharacterState.fromJson(
            Map<String, dynamic>.from(e as Map),
          );
          return MapEntry<String, CharacterState>(c.id, c);
        }),
      );

    _threads
      ..clear()
      ..addEntries(
        (json['threads'] as List<dynamic>? ?? const <dynamic>[]).map((
          dynamic e,
        ) {
          final ChatThread t = ChatThread.fromJson(
            Map<String, dynamic>.from(e as Map),
          );
          return MapEntry<String, ChatThread>(t.id, t);
        }),
      );

    _phone = json['phone'] == null
        ? const PhoneState()
        : PhoneState.fromJson(Map<String, dynamic>.from(json['phone'] as Map));
    _browser = json['browser'] == null
        ? const BrowserState()
        : BrowserState.fromJson(
            Map<String, dynamic>.from(json['browser'] as Map),
          );

    _inventory
      ..clear()
      ..addEntries(
        (json['inventory'] as List<dynamic>? ?? const <dynamic>[]).map((
          dynamic e,
        ) {
          final InventoryItem i = InventoryItem.fromJson(
            Map<String, dynamic>.from(e as Map),
          );
          return MapEntry<String, InventoryItem>(i.id, i);
        }),
      );

    _evidence
      ..clear()
      ..addEntries(
        (json['evidence'] as List<dynamic>? ?? const <dynamic>[]).map((
          dynamic e,
        ) {
          final EvidenceEntry v = EvidenceEntry.fromJson(
            Map<String, dynamic>.from(e as Map),
          );
          return MapEntry<String, EvidenceEntry>(v.id, v);
        }),
      );

    _journal
      ..clear()
      ..addAll(
        (json['journal'] as List<dynamic>? ?? const <dynamic>[]).map(
          (dynamic e) =>
              JournalEntry.fromJson(Map<String, dynamic>.from(e as Map)),
        ),
      );

    _objectives
      ..clear()
      ..addEntries(
        (json['objectives'] as List<dynamic>? ?? const <dynamic>[]).map((
          dynamic e,
        ) {
          final Objective o = Objective.fromJson(
            Map<String, dynamic>.from(e as Map),
          );
          return MapEntry<String, Objective>(o.id, o);
        }),
      );

    _achievements
      ..clear()
      ..addEntries(
        (json['achievements'] as List<dynamic>? ?? const <dynamic>[]).map((
          dynamic e,
        ) {
          final Achievement a = Achievement.fromJson(
            Map<String, dynamic>.from(e as Map),
          );
          return MapEntry<String, Achievement>(a.id, a);
        }),
      );

    _gallery
      ..clear()
      ..addEntries(
        (json['gallery'] as List<dynamic>? ?? const <dynamic>[]).map((
          dynamic e,
        ) {
          final GalleryUnlock g = GalleryUnlock.fromJson(
            Map<String, dynamic>.from(e as Map),
          );
          return MapEntry<String, GalleryUnlock>(g.id, g);
        }),
      );

    _wallet = json['wallet'] == null
        ? const Wallet()
        : Wallet.fromJson(Map<String, dynamic>.from(json['wallet'] as Map));
    _profile = json['profile'] == null
        ? const PlayerProfile()
        : PlayerProfile.fromJson(
            Map<String, dynamic>.from(json['profile'] as Map),
          );

    _seenLabels
      ..clear()
      ..addAll(
        (json['seen'] as List<dynamic>? ?? const <dynamic>[]).map(
          (dynamic e) => e.toString(),
        ),
      );
    _pickedChoices
      ..clear()
      ..addAll(
        (json['picked'] as List<dynamic>? ?? const <dynamic>[]).map(
          (dynamic e) => e.toString(),
        ),
      );
    _visitedUrls
      ..clear()
      ..addAll(
        (json['visited'] as List<dynamic>? ?? const <dynamic>[]).map(
          (dynamic e) => e.toString(),
        ),
      );

    episodeId = json['episodeId'] as String? ?? '';
    currentScene = json['scene'] as String? ?? '';
    currentLabel = json['label'] as String? ?? '';
    background = json['background'] as String?;
    musicTrack = json['music'] as String?;
    musicVolume = (json['musicVolume'] as num?)?.toDouble() ?? 0.6;
    activeThreadId = json['activeThread'] as String?;
    theme = json['theme'] as String? ?? 'safe';

    _touch(GameStateSlice.everything);
  }

  static String _titleCase(String value) => value
      .split(RegExp(r'[_\s]+'))
      .where((String part) => part.isNotEmpty)
      .map(
        (String part) =>
            part[0].toUpperCase() + part.substring(1).toLowerCase(),
      )
      .join(' ');
}
