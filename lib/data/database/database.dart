import 'package:drift/drift.dart';
import 'connection.dart';

part 'database.g.dart';

// ── Tabele ──────────────────────────────────────────────────────────

class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get baseUrl => text()();
  TextColumn get apiKeyRef => text().nullable()();
  BoolColumn get apiKeyNeedsReentry =>
      boolean().withDefault(const Constant(false))();
  TextColumn get serverVersion => text().nullable()();
  TextColumn get featureFlagsJson => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get lastUsedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get color => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Chats extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().nullable()();
  TextColumn get profileId => text().nullable().references(
    Profiles,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get modelId => text().nullable()();
  TextColumn get systemPrompt => text().nullable()();
  TextColumn get parametersJson => text().nullable()();
  TextColumn get folderId =>
      text().nullable().references(Folders, #id, onDelete: KeyAction.setNull)();
  // INVARIANT (manifest 9): activeLeafMessageId BEZ FK constraint (cykliczna zależność chats↔messages).
  // Repository pilnuje: (1) deleteMessage przestawia na parent/NULL przed usunięciem,
  // (2) loadChat ma fallback do MAX(created_at) WHERE is_partial=0 gdy wskazuje na nieistniejący rekord.
  TextColumn get activeLeafMessageId => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get chatId =>
      text().references(Chats, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()();
  TextColumn get content => text().nullable()();
  TextColumn get reasoning => text().nullable()();
  TextColumn get modelUsed => text().nullable()();
  TextColumn get parametersJson => text().nullable()();
  TextColumn get alternativeResponsesJson => text().nullable()();
  IntColumn get tokensIn => integer().nullable()();
  IntColumn get tokensOut => integer().nullable()();
  RealColumn get tokensPerSec => real().nullable()();
  TextColumn get parentId => text().nullable().references(
    Messages,
    #id,
    onDelete: KeyAction.restrict,
  )();
  BoolColumn get isPartial => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class MessageAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get messageId =>
      text().references(Messages, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  TextColumn get path => text()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get sizeBytes => integer().nullable()();
  TextColumn get metadataJson => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Personas extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get emoji => text().nullable()();
  TextColumn get systemPrompt => text().nullable()();
  TextColumn get defaultParametersJson => text().nullable()();
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class PromptLibrary extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get content => text()();
  TextColumn get category => text().nullable()();
  TextColumn get tagsJson => text().nullable()();
  TextColumn get slashAlias => text().nullable()();
  TextColumn get suggestedParametersJson => text().nullable()();
  TextColumn get source => text()();
  TextColumn get sourceUrl => text().nullable()();
  IntColumn get sourceLastFetchedAt => integer().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  IntColumn get lastUsedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserVariables extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

// ── Baza ────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    Profiles,
    Folders,
    Chats,
    Messages,
    MessageAttachments,
    Personas,
    PromptLibrary,
    UserVariables,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();

      // FTS5 — Drift nie tworzy virtual tables przez createAll(), robimy ręcznie
      await customStatement(
        'CREATE VIRTUAL TABLE messages_fts USING fts5('
        'content, reasoning, message_id UNINDEXED, chat_id UNINDEXED);',
      );
      await customStatement(
        'CREATE VIRTUAL TABLE chats_fts USING fts5('
        'title, chat_id UNINDEXED);',
      );

      // Triggery messages → messages_fts
      await customStatement('''
            CREATE TRIGGER messages_fts_ai AFTER INSERT ON messages BEGIN
              INSERT INTO messages_fts(content, reasoning, message_id, chat_id)
              VALUES (new.content, COALESCE(new.reasoning, ''), new.id, new.chat_id);
            END;''');
      await customStatement('''
            CREATE TRIGGER messages_fts_ad AFTER DELETE ON messages BEGIN
              DELETE FROM messages_fts WHERE message_id = old.id;
            END;''');
      await customStatement('''
            CREATE TRIGGER messages_fts_au AFTER UPDATE OF content, reasoning ON messages BEGIN
              DELETE FROM messages_fts WHERE message_id = old.id;
              INSERT INTO messages_fts(content, reasoning, message_id, chat_id)
              VALUES (new.content, COALESCE(new.reasoning, ''), new.id, new.chat_id);
            END;''');

      // Triggery chats → chats_fts
      await customStatement('''
            CREATE TRIGGER chats_fts_ai AFTER INSERT ON chats BEGIN
              INSERT INTO chats_fts(title, chat_id) VALUES (COALESCE(new.title, ''), new.id);
            END;''');
      await customStatement('''
            CREATE TRIGGER chats_fts_ad AFTER DELETE ON chats BEGIN
              DELETE FROM chats_fts WHERE chat_id = old.id;
            END;''');
      await customStatement('''
            CREATE TRIGGER chats_fts_au AFTER UPDATE OF title ON chats BEGIN
              DELETE FROM chats_fts WHERE chat_id = old.id;
              INSERT INTO chats_fts(title, chat_id) VALUES (COALESCE(new.title, ''), new.id);
            END;''');

      // Indeksy (manifest sekcja 9)
      await customStatement(
        'CREATE INDEX idx_profiles_last_used ON profiles(last_used_at DESC);',
      );
      await customStatement(
        'CREATE INDEX idx_chats_updated_at ON chats(updated_at DESC);',
      );
      await customStatement(
        'CREATE INDEX idx_chats_profile_updated ON chats(profile_id, updated_at DESC);',
      );
      await customStatement(
        'CREATE INDEX idx_chats_folder ON chats(folder_id);',
      );
      await customStatement(
        'CREATE INDEX idx_messages_chat_created ON messages(chat_id, created_at);',
      );
      await customStatement(
        'CREATE INDEX idx_messages_parent ON messages(parent_id);',
      );
      await customStatement(
        'CREATE INDEX idx_messages_model ON messages(model_used);',
      );
      await customStatement(
        'CREATE INDEX idx_attachments_message ON message_attachments(message_id);',
      );
      await customStatement(
        'CREATE UNIQUE INDEX idx_prompts_slash ON prompt_library(slash_alias) WHERE slash_alias IS NOT NULL;',
      );
      await customStatement(
        'CREATE INDEX idx_prompts_library_view ON prompt_library(category, is_favorite DESC, usage_count DESC);',
      );
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // TODO (manifest 9.1): downgrade detection + backup przed migracją — dochodzi gdy schemaVersion > 1
    },
  );
}
