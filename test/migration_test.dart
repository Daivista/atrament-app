import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atrament_app/core/database/database.dart';
import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v1.dart';

// Warstwa FTS v1 — te same customStatement co w onCreate. Helper SchemaV1 zna
// tylko 8 tabel (FTS jest customStatement, niewidzialne dla Drift), więc żeby
// test odtwarzał REALNĄ v1 (a nie modelową), doszywamy ją ręcznie przed migracją.
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

  // TEST 1 — struktura + FK. migrateAndValidate porównuje schemat po migracji
  // ze SchemaV2: potwierdza parent_id RESTRICT->SET NULL i nietknięte kolumny.
  test('struktura: migracja v1 -> v2 zgodna ze SchemaV2', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  // TEST 2 — dane + FTS + zachowanie FK na REALNEJ v1 (8 tabel + warstwa FTS).
  test('dane i FTS przeżywają migrację, komplet obiektów wraca', () async {
    final schema = await verifier.schemaAt(1);

    // 1. Odtwórz realną v1: warstwa FTS + dane (łańcuch parent_id: m2 -> m1)
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

    // 2. Migracja v1 -> v2 (otwarcie AppDatabase na bazie v1 odpala onUpgrade)
    final db = AppDatabase(schema.newConnection());
    await db.customSelect('SELECT 1').get(); // wymusza otwarcie + migrację

    // 3a. Dane przeżyły, łańcuch parent_id nietknięty
    final msgs = await db
        .customSelect('SELECT id, parent_id FROM messages ORDER BY created_at')
        .get();
    expect(msgs.length, 2);
    expect(msgs[0].read<String>('id'), 'm1');
    expect(msgs[1].read<String?>('parent_id'), 'm1');

    // 3b. FK SET NULL behawioralnie: usuń rodzica m1 -> parent_id m2 = NULL (nie blokada)
    await db.customStatement("DELETE FROM messages WHERE id = 'm1';");
    final m2 = await db
        .customSelect("SELECT parent_id FROM messages WHERE id = 'm2'")
        .getSingle();
    expect(
      m2.read<String?>('parent_id'),
      isNull,
      reason: 'SET NULL: dziecko zostaje, parent_id wyzerowany',
    );

    // 3c. Komplet obiektów po migracji (sqlite_master — Drift ich nie zna)
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

    // 3d. FTS dalej strzela (trigger messages_fts_ai działa po migracji)
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
}
