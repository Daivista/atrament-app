import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database.dart';

class MessageRepository {
  final AppDatabase _db;
  MessageRepository(this._db);

  Future<String> createChat({String? profileId, String? modelId}) async {
    final id = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db
        .into(_db.chats)
        .insert(
          ChatsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            profileId: Value(profileId),
            modelId: Value(modelId),
          ),
        );
    return id;
  }

  Future<String> appendMessage({
    required String chatId,
    required String role,
    required String content,
    String? reasoning,
    String? parentId,
    String? modelUsed,
    bool isPartial = false,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    await _db
        .into(_db.messages)
        .insert(
          MessagesCompanion.insert(
            id: id,
            chatId: chatId,
            role: role,
            createdAt: now,
            content: Value(content),
            reasoning: Value(reasoning),
            parentId: Value(parentId),
            modelUsed: Value(modelUsed),
            isPartial: Value(isPartial),
          ),
        );

    final chat = await (_db.select(
      _db.chats,
    )..where((c) => c.id.equals(chatId))).getSingleOrNull();
    String? newTitle;
    if (chat != null &&
        (chat.title == null || chat.title!.isEmpty) &&
        role == 'user') {
      newTitle = _autoTitle(content);
    }

    await (_db.update(_db.chats)..where((c) => c.id.equals(chatId))).write(
      ChatsCompanion(
        activeLeafMessageId: Value(id),
        updatedAt: Value(now),
        title: newTitle != null ? Value(newTitle) : const Value.absent(),
      ),
    );
    return id;
  }

  static String _autoTitle(String content) {
    final clean = content.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.length <= 40) return clean;
    final cut = clean.substring(0, 40);
    final lastSpace = cut.lastIndexOf(' ');
    final base = lastSpace > 20 ? cut.substring(0, lastSpace) : cut;
    return '$base…';
  }

  Future<void> updateChatTitle(String chatId, String title) {
    return (_db.update(_db.chats)..where((c) => c.id.equals(chatId))).write(
      ChatsCompanion(title: Value(title.trim().isEmpty ? null : title.trim())),
    );
  }

  /// Usuwa czat wraz z wiadomościami.
  /// Manifest 9 ma messages.parent_id ON DELETE RESTRICT (chroni przed
  /// przypadkowym usunięciem wiadomości-rodzica). To wchodzi w konflikt z
  /// CASCADE delete chatu — w transakcji najpierw zerwiemy więzy parent_id,
  /// potem delete chatu uruchomi czysto CASCADE na chat_id.
  Future<void> deleteChat(String chatId) async {
    await _db.transaction(() async {
      await (_db.update(_db.messages)..where((m) => m.chatId.equals(chatId)))
          .write(const MessagesCompanion(parentId: Value(null)));
      await (_db.delete(_db.chats)..where((c) => c.id.equals(chatId))).go();
    });
  }

  Future<List<Message>> getMessages(String chatId) {
    return (_db.select(_db.messages)
          ..where((m) => m.chatId.equals(chatId))
          ..orderBy([(m) => OrderingTerm(expression: m.createdAt)]))
        .get();
  }

  Future<Chat?> getChat(String chatId) {
    return (_db.select(
      _db.chats,
    )..where((c) => c.id.equals(chatId))).getSingleOrNull();
  }

  Stream<List<Chat>> watchChats() {
    return (_db.select(_db.chats)..orderBy([
          (c) => OrderingTerm(expression: c.updatedAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  Future<Chat?> getLatestChat() {
    return (_db.select(_db.chats)
          ..orderBy([
            (c) =>
                OrderingTerm(expression: c.updatedAt, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }
}
