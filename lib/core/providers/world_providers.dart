import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/engine.dart';
import 'engine_providers.dart';

/// Derived, read-only views of the live [GameState].
///
/// `GameState` is a mutable aggregate, so these providers key off the session
/// revision counter: one bump, one rebuild, no deep copies.
T _read<T>(Ref ref, T Function(GameState state) selector, T fallback) {
  ref.watch(gameSessionProvider.select((GameSession s) => s.revision));
  final GameState? state = ref.read(gameSessionProvider).state;
  return state == null ? fallback : selector(state);
}

final Provider<PhoneState> phoneStateProvider = Provider<PhoneState>(
    (ref) => _read(ref, (GameState s) => s.phone, const PhoneState()));

final Provider<BrowserState> browserStateProvider = Provider<BrowserState>(
    (ref) => _read(ref, (GameState s) => s.browser, const BrowserState()));

final Provider<Wallet> walletProvider = Provider<Wallet>(
    (ref) => _read(ref, (GameState s) => s.wallet, const Wallet()));

final Provider<PlayerProfile> profileProvider = Provider<PlayerProfile>(
    (ref) => _read(ref, (GameState s) => s.profile, const PlayerProfile()));

final Provider<List<InstalledApp>> installedAppsProvider =
    Provider<List<InstalledApp>>((ref) => _read(
          ref,
          (GameState s) => s.phone.apps
              .where((InstalledApp a) => !a.hidden)
              .toList(growable: false),
          const <InstalledApp>[],
        ));

final Provider<List<GameNotification>> notificationsProvider =
    Provider<List<GameNotification>>((ref) => _read(
          ref,
          (GameState s) => s.phone.notifications,
          const <GameNotification>[],
        ));

final Provider<int> unreadCountProvider = Provider<int>((ref) => _read(
      ref,
      (GameState s) => s.phone.unreadNotifications,
      0,
    ));

/// Conversations for one app (`messenger`, `makelove`…), newest first.
final ProviderFamily<List<ChatThread>, String> threadsForAppProvider =
    Provider.family<List<ChatThread>, String>(
  (ref, String app) => _read(
    ref,
    (GameState s) => s.threadsForApp(app),
    const <ChatThread>[],
  ),
);

final ProviderFamily<ChatThread?, String> threadProvider =
    Provider.family<ChatThread?, String>(
  (ref, String id) => _read(ref, (GameState s) => s.thread(id), null),
);

final Provider<ChatThread?> activeThreadProvider = Provider<ChatThread?>(
  (ref) => _read(ref, (GameState s) {
    final String? id = s.activeThreadId;
    return id == null ? null : s.thread(id);
  }, null),
);

final Provider<Map<String, CharacterState>> charactersProvider =
    Provider<Map<String, CharacterState>>((ref) => _read(
          ref,
          (GameState s) => s.characters,
          const <String, CharacterState>{},
        ));

final ProviderFamily<CharacterState?, String> characterProvider =
    Provider.family<CharacterState?, String>(
  (ref, String id) => _read(ref, (GameState s) => s.character(id), null),
);

final Provider<Map<String, Relationship>> relationshipsProvider =
    Provider<Map<String, Relationship>>((ref) => _read(
          ref,
          (GameState s) => s.relationships,
          const <String, Relationship>{},
        ));

final Provider<List<GalleryUnlock>> galleryProvider =
    Provider<List<GalleryUnlock>>((ref) => _read(
          ref,
          (GameState s) => s.gallery.values.toList(growable: false),
          const <GalleryUnlock>[],
        ));

final Provider<List<Objective>> objectivesProvider = Provider<List<Objective>>(
    (ref) => _read(
        ref,
        (GameState s) => s.objectives.values.toList(growable: false),
        const <Objective>[]));

final Provider<List<JournalEntry>> journalProvider = Provider<List<JournalEntry>>(
    (ref) => _read(ref, (GameState s) => s.journal, const <JournalEntry>[]));

final Provider<List<EvidenceEntry>> evidenceProvider =
    Provider<List<EvidenceEntry>>((ref) => _read(
          ref,
          (GameState s) => s.evidence.values.toList(growable: false),
          const <EvidenceEntry>[],
        ));

final Provider<PhoneCall?> activeCallProvider = Provider<PhoneCall?>(
    (ref) => _read(ref, (GameState s) => s.phone.activeCall, null));

/// Which app the phone shell should be showing.
final Provider<String?> currentAppProvider = Provider<String?>(
    (ref) => _read(ref, (GameState s) => s.phone.currentApp, null));
