import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/repositories/player_repository.dart';
import '../../database/repositories/save_repository.dart';
import '../../engine/engine.dart';
import 'audio_controller.dart';
import 'database_providers.dart';
import 'engine_providers.dart';

/// Result of opening the database and reading the player's account.
class Bootstrap {
  const Bootstrap({
    required this.profile,
    required this.settings,
    required this.wallet,
    required this.onboarded,
    required this.hasSave,
    this.lastSave,
  });

  final PlayerProfile profile;
  final EngineSettings settings;
  final Wallet wallet;

  /// False until the player has been through Welcome → Player Setup.
  final bool onboarded;
  final bool hasSave;
  final SaveSlotSummary? lastSave;
}

/// Runs once at startup, before the studio animation finishes.
final FutureProvider<Bootstrap> bootstrapProvider =
    FutureProvider<Bootstrap>((ref) async {
  final PlayerRepository players = ref.watch(playerRepositoryProvider);
  final SaveRepository saves = ref.watch(saveRepositoryProvider);

  final PlayerProfile profile = await players.loadProfile();
  final EngineSettings settings = await players.loadSettings();
  final Wallet wallet = await players.loadWallet();
  final bool onboarded = await players.isOnboarded();
  final SaveSlotSummary? lastSave = await saves.mostRecent();

  ref.read(audioControllerProvider).applySettings(settings);
  ref.read(gameSessionProvider.notifier).applySettings(settings);

  return Bootstrap(
    profile: profile,
    settings: settings,
    wallet: wallet,
    onboarded: onboarded,
    hasSave: lastSave != null,
    lastSave: lastSave,
  );
});

/// Live playback settings. Changing one applies instantly to a running episode.
class SettingsController extends Notifier<EngineSettings> {
  @override
  EngineSettings build() {
    final Bootstrap? boot = ref.watch(bootstrapProvider).valueOrNull;
    return boot?.settings ?? const EngineSettings();
  }

  Future<void> update(EngineSettings settings) async {
    state = settings;
    ref.read(gameSessionProvider.notifier).applySettings(settings);
    ref.read(audioControllerProvider).applySettings(settings);
    await ref.read(playerRepositoryProvider).saveSettings(settings);
  }

  Future<void> patch(EngineSettings Function(EngineSettings) fn) =>
      update(fn(state));
}

final NotifierProvider<SettingsController, EngineSettings>
    settingsControllerProvider =
    NotifierProvider<SettingsController, EngineSettings>(
        SettingsController.new);

/// The player's saved games, refreshed by `ref.invalidate`.
final FutureProvider<List<SaveSlotSummary>> saveSlotsProvider =
    FutureProvider<List<SaveSlotSummary>>(
        (ref) => ref.watch(saveRepositoryProvider).listSlots());

/// Profile editing (Player Setup screen and Settings → Profile).
class ProfileController extends Notifier<PlayerProfile> {
  @override
  PlayerProfile build() =>
      ref.watch(bootstrapProvider).valueOrNull?.profile ??
      const PlayerProfile();

  Future<void> save(PlayerProfile profile, {bool onboarded = true}) async {
    state = profile;
    await ref
        .read(playerRepositoryProvider)
        .saveProfile(profile, onboarded: onboarded);
    ref.invalidate(bootstrapProvider);
  }
}

final NotifierProvider<ProfileController, PlayerProfile>
    profileControllerProvider =
    NotifierProvider<ProfileController, PlayerProfile>(ProfileController.new);
