import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// Wersja schematu aplikacji — JEDNO źródło prawdy.
/// Używana przez AppDatabase.schemaVersion oraz przez backup (cel migracji).
const int kAppSchemaVersion = 2;

/// Rzucane gdy baza jest w NOWSZEJ wersji niż obsługuje aplikacja
/// (user zainstalował starszą wersję APK na nowszej bazie).
/// Łapane w warstwie UI (gdy powstanie app shell) → ekran eksport/reset.
class DatabaseDowngradeException implements Exception {
  final int from;
  final int to;
  DatabaseDowngradeException({required this.from, required this.to});

  @override
  String toString() =>
      'DatabaseDowngradeException: baza w wersji $from, aplikacja obsługuje $to '
      '(zainstalowano starszą wersję aplikacji na nowszej bazie).';
}

/// Backup pliku bazy PRZED migracją. Wołane z openConnection() zanim Drift
/// otworzy bazę i uruchomi onUpgrade. Czyste od path_provider → testowalne.
///
/// Kopiuje plik tylko gdy migracja faktycznie nastąpi (0 < user_version < target).
/// Trzyma WYŁĄCZNIE najnowszy backup (kasuje starsze przed zapisem), żeby po
/// wielu migracjach nie urosło do sterty kopii bazy.
Future<void> backupBeforeMigration({
  required File dbFile,
  required Directory baseDir,
  required int targetVersion,
}) async {
  if (!await dbFile.exists()) return;

  // Odczyt user_version surowym sqlite3 (read-only, żeby nie tworzyć -wal/-shm)
  int currentVersion;
  try {
    final probe = sqlite3.open(dbFile.path, mode: OpenMode.readOnly);
    try {
      currentVersion =
          probe.select('PRAGMA user_version').first['user_version'] as int;
    } finally {
      probe.close();
    }
  } catch (_) {
    return; // nie udało się odczytać wersji — pomijamy backup, nie blokujemy startu
  }

  // Migracja nastąpi tylko gdy 0 < current < target
  if (currentVersion <= 0 || currentVersion >= targetVersion) return;

  final backupsDir = Directory(p.join(baseDir.path, 'backups'));
  if (!await backupsDir.exists()) {
    await backupsDir.create(recursive: true);
  }

  // Sprzątanie: zostaw tylko najnowszy backup (kasuj poprzednie przed zapisem)
  final existing = await backupsDir.list().toList();
  for (final entity in existing) {
    if (entity is File && p.basename(entity.path).startsWith('db_v')) {
      await entity.delete();
    }
  }

  await dbFile.copy(p.join(backupsDir.path, 'db_v$currentVersion.sqlite'));
}

/// Otwiera bazę leniwie (dopiero przy pierwszym użyciu).
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'atrament.db'));

    // Android workaround: sqlite3 pisze pliki tymczasowe do /tmp (zabronione na Androidzie)
    final tempDir = await getTemporaryDirectory();
    sqlite3.tempDirectory = tempDir.path;

    // Commit B: backup pliku bazy przed ewentualną migracją
    await backupBeforeMigration(
      dbFile: file,
      baseDir: dbFolder,
      targetVersion: kAppSchemaVersion,
    );

    return NativeDatabase.createInBackground(file);
  });
}
