import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database.dart';
import 'chat_parameters.dart';

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

  /// Dodaje wiadomość do rozmowy. Sesja A1: opcjonalny `parameters` zapisuje
  /// snapshot do `messages.parameters_json` (audit z czasu wysłania).
  Future<String> appendMessage({
    required String chatId,
    required String role,
    required String content,
    String? reasoning,
    String? parentId,
    String? modelUsed,
    ChatParameters? parameters,
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
            parametersJson: Value(
              parameters != null ? jsonEncode(parameters.toJson()) : null,
            ),
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

  /// Resume flow (manifest 7.6): konkatenacja dokończenia do partial.
  /// Perf-note 9.5: jeden UPDATE po streamie, nie per chunk.
  /// Uwaga: parameters_json NIE jest aktualizowany — snapshot zostaje z czasu
  /// pierwotnego wysłania (continuation to recovery, nie nowy snapshot).
  Future<void> appendContinuation(
    String messageId,
    String additionalContent, {
    String? additionalReasoning,
  }) async {
    final msg = await (_db.select(
      _db.messages,
    )..where((m) => m.id.equals(messageId))).getSingleOrNull();
    if (msg == null) return;

    final mergedContent = (msg.content ?? '') + additionalContent;
    final mergedReasoning = (msg.reasoning ?? '') + (additionalReasoning ?? '');

    await (_db.update(
      _db.messages,
    )..where((m) => m.id.equals(messageId))).write(
      MessagesCompanion(
        content: Value(mergedContent),
        reasoning: Value(mergedReasoning.isEmpty ? null : mergedReasoning),
        isPartial: const Value(false),
      ),
    );
    await (_db.update(_db.chats)..where((c) => c.id.equals(msg.chatId))).write(
      ChatsCompanion(updatedAt: Value(DateTime.now().millisecondsSinceEpoch)),
    );
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

  // ──────────────────────────────────────────────────────────────────────────
  // Sesja A1 — parametry inference per rozmowa (manifest sekcja 6 + 9.2).
  // chats.parameters_json przechowuje ChatParameters jako JSON. NULL = rozmowa
  // nigdy nie miała jawnie ustawionych parametrów — fallback do ChatParameters().
  // ──────────────────────────────────────────────────────────────────────────

  /// Odczyt parametrów rozmowy. NULL lub błąd parsowania → ChatParameters()
  /// (hardcoded defaults z manifestu sekcja 9.2).
  Future<ChatParameters> getChatParameters(String chatId) async {
    final chat = await (_db.select(
      _db.chats,
    )..where((c) => c.id.equals(chatId))).getSingleOrNull();
    if (chat == null || chat.parametersJson == null) {
      return const ChatParameters();
    }
    try {
      final json = jsonDecode(chat.parametersJson!) as Map<String, dynamic>;
      return ChatParameters.fromJson(json);
    } catch (_) {
      // Defensywny fallback — uszkodzony JSON nie powinien crashować appki.
      return const ChatParameters();
    }
  }

  /// Zapis parametrów rozmowy (wywoływane przez ChatParametersSheet w A2).
  Future<void> updateChatParameters(String chatId, ChatParameters params) {
    return (_db.update(_db.chats)..where((c) => c.id.equals(chatId))).write(
      ChatsCompanion(parametersJson: Value(jsonEncode(params.toJson()))),
    );
  }

  /// Zmiana modelu przypisanego do rozmowy. NULL = "użyj domyślnego z profilu"
  /// (czyli models.first w chat_target — dzisiejsze zachowanie).
  Future<void> updateChatModel(String chatId, String? modelId) {
    return (_db.update(_db.chats)..where((c) => c.id.equals(chatId))).write(
      ChatsCompanion(modelId: Value(modelId)),
    );
  }

  /// Zmiana system promptu rozmowy. Pusty string traktowany jak NULL (cleanup).
  Future<void> updateChatSystemPrompt(String chatId, String? systemPrompt) {
    final cleaned = systemPrompt?.trim();
    final value = (cleaned == null || cleaned.isEmpty) ? null : cleaned;
    return (_db.update(_db.chats)..where((c) => c.id.equals(chatId))).write(
      ChatsCompanion(systemPrompt: Value(value)),
    );
  }

  /// v2: workaround zbędny. FK messages.chat_id -> chats ON DELETE CASCADE
  /// usuwa wiadomości, a messages.parent_id -> messages ON DELETE SET NULL
  /// zdejmuje blokadę, którą dawał RESTRICT (nie trzeba ręcznie zerować parent_id).
  Future<void> deleteChat(String chatId) async {
    await (_db.delete(_db.chats)..where((c) => c.id.equals(chatId))).go();
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
