import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/app_database.dart';
import '../../database/repositories/collection_repository.dart';
import '../../database/repositories/player_repository.dart';
import '../../database/repositories/save_repository.dart';

/// The single SQLite connection for the whole app.
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((ref) {
  final AppDatabase database = AppDatabase.open();
  ref.onDispose(database.close);
  return database;
});

final Provider<SaveRepository> saveRepositoryProvider =
    Provider<SaveRepository>(
      (ref) => SaveRepository(ref.watch(appDatabaseProvider)),
    );

final Provider<PlayerRepository> playerRepositoryProvider =
    Provider<PlayerRepository>(
      (ref) => PlayerRepository(ref.watch(appDatabaseProvider)),
    );

final Provider<CollectionRepository> collectionRepositoryProvider =
    Provider<CollectionRepository>(
      (ref) => CollectionRepository(ref.watch(appDatabaseProvider)),
    );
