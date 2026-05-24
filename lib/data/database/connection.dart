import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

// Otwiera bazę leniwie (dopiero przy pierwszym użyciu).
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'atrament.db'));

    // ★ Android workaround (manifest, notatka do koordynatora):
    // sqlite3 domyślnie pisze pliki tymczasowe do /tmp, czego Android zabrania.
    // Przekierowujemy temp na katalog cache aplikacji.
    final tempDir = await getTemporaryDirectory();
    sqlite3.tempDirectory = tempDir.path;

    return NativeDatabase.createInBackground(file);
  });
}
