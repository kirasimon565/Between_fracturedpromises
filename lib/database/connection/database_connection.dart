import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the SQLite file lazily, off the UI isolate.
///
/// `createInBackground` moves every statement to a background isolate, which
/// matters because the engine autosaves a full snapshot after every scene.
///
/// SQLite 3.x (package:sqlite3) bundles its native library automatically via
/// Flutter asset hooks, so no separate `sqlite3_flutter_libs` dependency and
/// no `applyWorkaroundToOpenSqlite3OnOldAndroidVersions()` call are needed.
QueryExecutor openDatabaseConnection(String fileName) {
  return LazyDatabase(() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dir.path, fileName));

    return NativeDatabase.createInBackground(file, logStatements: false);
  });
}

/// Ephemeral database for tests and the script sandbox.
QueryExecutor openMemoryConnection() => NativeDatabase.memory();
