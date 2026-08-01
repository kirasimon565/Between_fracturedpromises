import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

/// Opens the SQLite file lazily, off the UI isolate.
///
/// `createInBackground` moves every statement to a background isolate, which
/// matters because the engine autosaves a full snapshot after every scene.
QueryExecutor openDatabaseConnection(String fileName) {
  return LazyDatabase(() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dir.path, fileName));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file, logStatements: false);
  });
}

/// Ephemeral database for tests and the script sandbox.
QueryExecutor openMemoryConnection() => NativeDatabase.memory();
