import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:atrament_app/core/database/database.dart';
import 'package:atrament_app/core/database/connection.dart';
import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v1.dart';

const _v1FtsLayer = <String>[
  'CREATE VIRTUAL TABLE messages_fts USING fts5(content, reasoning, message_id UNINDEXED, chat_id UNINDEXED);',
  'CREATE VIRTUAL TABLE chats_fts USING fts5(title, chat_id UNINDEXED);',
  '''CREATE TRIGGER messages_fts_ai AFTER INSERT ON messages BEGIN
       INSERT INTO messages_fts(content, reasoning, message_id, chat_id)
       VALUES (new.content, COALESCE(new.reasoning, ''), new.id, new.chat_id);
     END;''',
  '''CREATE TRIGGER messages_fts_ad AFTER DELETE ON messages BEGIN
       DELETE FROM messages_fts WHERE message_id = old.id;
     END;''',
  '''CREATE TRIGGER messages_fts_au AFTER UPDATE OF content, reasoning ON messages BEGIN
       DELETE FROM messages_fts WHERE message_id = old.id;
       INSERT INTO messages_fts(content, reasoning, message_id, chat_id)
       VALUES (new.content, COALESCE(new.reasoning, ''), new.id, new.chat_id);
     END;''',
  '''CREATE TRIGGER chats_fts_ai AFTER INSERT ON chats BEGIN
       INSERT INTO chats_fts(title, chat_id) VALUES (COALESCE(new.title, ''), new.id);
     END;''',
  '''CREATE TRIGGER chats_fts_ad AFTER DELETE ON chats BEGIN
       DELETE FROM chats_fts WHERE chat_id = old.id;
     END;''',
  '''CREATE TRIGGER chats_fts_au AFTER UPDATE OF title ON chats BEGIN
       DELETE FROM chats_fts WHERE chat_id = old.id;
       INSERT INTO chats_fts(title, chat_id) VALUES (COALESCE(new.title, ''), new.id);
     END;''',
  'CREATE INDEX idx_profiles_last_used ON profiles(last_used_at DESC);',
  'CREATE INDEX idx_chats_updated_at ON chats(updated_at DESC);',
  'CREATE INDEX idx_chats_profile_updated ON chats(profile_id, updated_at DESC);',
  'CREATE INDEX idx_chats_folder ON chats(folder_id);',
  'CREATE INDEX idx_messages_chat_created ON messages(chat_id, created_at);',
  'CREATE INDEX idx_messages_parent ON messages(parent_id);',
  'CREATE INDEX idx_messages_model ON messages(model_used);',
  'CREATE INDEX idx_attachments_message ON message_attachments(message_id);',
  'CREATE UNIQUE INDEX idx_prompts_slash ON prompt_library(slash_alias) WHERE slash_alias IS NOT NULL;',
  'CREATE INDEX idx_prompts_library_view ON prompt_library(category, is_favorite DESC, usage_count DESC);',
];

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('struktura: migracja v1 -> v2 zgodna ze SchemaV2', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test('dane i FTS przeżywają migrację, komplet obiektów wraca', () async {
    final schema = await verifier.schemaAt(1);

    final v1db = DatabaseAtV1(schema.newConnection());
    for (final stmt in _v1FtsLayer) {
      await v1db.customStatement(stmt);
    }
    await v1db.customStatement(
      "INSERT INTO chats (id, title, created_at, updated_at) VALUES ('c1', 'Czat', 1, 1);",
    );
    await v1db.customStatement(
      "INSERT INTO messages (id, chat_id, role, content, is_partial, created_at) "
      "VALUES ('m1', 'c1', 'user', 'pierwsza wiadomosc', 0, 1);",
    );
    await v1db.customStatement(
      "INSERT INTO messages (id, chat_id, role, content, parent_id, is_partial, created_at) "
      "VALUES ('m2', 'c1', 'assistant', 'odpowiedz', 'm1', 0, 2);",
    );
    await v1db.close();

    final db = AppDatabase(schema.newConnection());
    await db.customSelect('SELECT 1').get();

    final msgs = await db
        .customSelect('SELECT id, parent_id FROM messages ORDER BY created_at')
        .get();
    expect(msgs.length, 2);
    expect(msgs[0].read<String>('id'), 'm1');
    expect(msgs[1].read<String?>('parent_id'), 'm1');

    await db.customStatement("DELETE FROM messages WHERE id = 'm1';");
    final m2 = await db
        .customSelect("SELECT parent_id FROM messages WHERE id = 'm2'")
        .getSingle();
    expect(
      m2.read<String?>('parent_id'),
      isNull,
      reason: 'SET NULL: dziecko zostaje, parent_id wyzerowany',
    );

    final triggers = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'trigger'")
        .get();
    expect(triggers.length, 6, reason: '3 triggery messages + 3 chats');

    final ftsTables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name LIKE 'messages_fts' OR name LIKE 'chats_fts'",
        )
        .get();
    expect(ftsTables.length, 2, reason: 'messages_fts + chats_fts');

    final indexes = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx\\_%' ESCAPE '\\'",
        )
        .get();
    expect(indexes.length, 10, reason: '10 indeksów aplikacji');

    await db.customStatement(
      "INSERT INTO messages (id, chat_id, role, content, is_partial, created_at) "
      "VALUES ('m3', 'c1', 'user', 'unikalnefraza', 0, 3);",
    );
    final hits = await db
        .customSelect(
          "SELECT message_id FROM messages_fts WHERE messages_fts MATCH 'unikalnefraza'",
        )
        .get();
    expect(
      hits.length,
      1,
      reason: 'trigger FTS po migracji indeksuje nowe wiadomości',
    );

    await db.close();
  });

  // TEST 3 (Commit B) — downgrade detection: baza nowsza niż appka.
  test('downgrade: nowsza baza rzuca DatabaseDowngradeException', () async {
    final raw = sqlite3.openInMemory();
    raw.execute('PRAGMA user_version = 99'); // udajemy bazę z przyszłej wersji
    final db = AppDatabase(NativeDatabase.opened(raw));
    await expectLater(
      db.customSelect('SELECT 1').get(),
      throwsA(isA<DatabaseDowngradeException>()),
    );
    await db.close();
  });

  // TEST 4 (Commit B) — backup przed migracją: kopiuje + trzyma tylko najnowszy.
  test('backup: kopiuje bazę przed migracją i sprząta stare', () async {
    final dir = await Directory.systemTemp.createTemp('atrament_backup_test');
    try {
      final dbFile = File(p.join(dir.path, 'atrament.db'));

      // Baza "v1" z zawartością
      final raw = sqlite3.open(dbFile.path);
      raw.execute('PRAGMA user_version = 1');
      raw.execute('CREATE TABLE t (x);');
      raw.execute("INSERT INTO t VALUES ('dane');");
      raw.dispose();

      // Stary backup który ma zostać sprzątnięty
      final backupsDir = Directory(p.join(dir.path, 'backups'));
      await backupsDir.create(recursive: true);
      await File(
        p.join(backupsDir.path, 'db_v0.sqlite'),
      ).writeAsString('stary');

      await backupBeforeMigration(
        dbFile: dbFile,
        baseDir: dir,
        targetVersion: 2,
      );

      expect(
        await File(p.join(backupsDir.path, 'db_v1.sqlite')).exists(),
        isTrue,
        reason: 'backup oczekującej migracji powstał',
      );
      expect(
        await File(p.join(backupsDir.path, 'db_v0.sqlite')).exists(),
        isFalse,
        reason: 'stary backup sprzątnięty',
      );

      // Baza już w wersji docelowej -> brak nowego backupu
      final raw2 = sqlite3.open(dbFile.path);
      raw2.execute('PRAGMA user_version = 2');
      raw2.dispose();
      final countBefore = backupsDir.listSync().length;
      await backupBeforeMigration(
        dbFile: dbFile,
        baseDir: dir,
        targetVersion: 2,
      );
      expect(
        backupsDir.listSync().length,
        countBefore,
        reason: 'brak migracji -> brak backupu',
      );
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
