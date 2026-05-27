import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database.dart';

/// Persystencja rozmów: tworzenie czatów, zapis wiadomości, wczytywanie.
/// Invariant (manifest 9): każdy append aktualizuje active_leaf_message_id
/// oraz updated_at chatu — w jednej operacji.
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

  /// Dodaje wiadomość + aktualizuje active_leaf i updated_at chatu.
  /// Performance-note 9.5: content commitowany RAZ (per wiadomość, nie per chunk).
  Future<String> appendMessage({
    required String chatId,
    required String role, // 'user' | 'assistant' | 'system'
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

    // INVARIANT (manifest 9): active_leaf wskazuje na ostatnią wiadomość w gałęzi.
    await (_db.update(_db.chats)..where((c) => c.id.equals(chatId))).write(
      ChatsCompanion(activeLeafMessageId: Value(id), updatedAt: Value(now)),
    );
    return id;
  }

  Future<List<Message>> getMessages(String chatId) {
    return (_db.select(_db.messages)
          ..where((m) => m.chatId.equals(chatId))
          ..orderBy([(m) => OrderingTerm(expression: m.createdAt)]))
        .get();
  }

  /// Najnowszy używany czat (po updated_at). Używane do auto-load przy starcie
  /// w wersji jednoekranowej — przy liście czatów (krok 2) to przestanie być potrzebne.
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
