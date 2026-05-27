import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/providers.dart';
import '../../profiles/data/profile_providers.dart';
import '../data/chat_models.dart';
import '../data/chat_providers.dart';
import '../data/message_repository.dart';

/// Cel rozmowy — reaktywny (StreamProvider zamiast FutureProvider.first).
final chatTargetProvider = StreamProvider<ChatTarget?>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.watchActiveProfileId().asyncMap((activeId) async {
    if (activeId == null) return null;
    final profiles = await repo.getAllProfiles();
    Profile? profile;
    for (final p in profiles) {
      if (p.id == activeId) {
        profile = p;
        break;
      }
    }
    if (profile == null) return null;
    final apiKey = await repo.getApiKey(profile.id);
    final models = await ref
        .read(apiClientProvider)
        .fetchModels(profile.baseUrl, apiKey: apiKey);
    return ChatTarget(
      baseUrl: profile.baseUrl,
      apiKey: apiKey,
      model: models.first,
      profileName: profile.name,
    );
  });
});

class ChatState {
  final String? chatId;
  final String? lastMessageId;
  final List<ChatMessage> messages;
  final String streamingContent;
  final String streamingReasoning;
  final bool isStreaming;
  final String? error;

  const ChatState({
    this.chatId,
    this.lastMessageId,
    this.messages = const [],
    this.streamingContent = '',
    this.streamingReasoning = '',
    this.isStreaming = false,
    this.error,
  });

  ChatState copyWith({
    String? chatId,
    String? lastMessageId,
    List<ChatMessage>? messages,
    String? streamingContent,
    String? streamingReasoning,
    bool? isStreaming,
    String? error,
    bool clearError = false,
    bool clearChatId = false,
  }) {
    return ChatState(
      chatId: clearChatId ? null : (chatId ?? this.chatId),
      lastMessageId: clearChatId ? null : (lastMessageId ?? this.lastMessageId),
      messages: messages ?? this.messages,
      streamingContent: streamingContent ?? this.streamingContent,
      streamingReasoning: streamingReasoning ?? this.streamingReasoning,
      isStreaming: isStreaming ?? this.isStreaming,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);

class ChatController extends Notifier<ChatState> {
  CancelToken? _cancelToken;

  @override
  ChatState build() {
    Future.microtask(_loadLatestChat);
    return const ChatState();
  }

  Future<void> _loadLatestChat() async {
    try {
      final repo = ref.read(messageRepositoryProvider);
      final latest = await repo.getLatestChat();
      if (latest == null) return;
      final dbMsgs = await repo.getMessages(latest.id);
      state = state.copyWith(
        chatId: latest.id,
        lastMessageId: latest.activeLeafMessageId,
        messages: dbMsgs
            .map((m) => ChatMessage(m.role, m.content ?? ''))
            .toList(),
      );
    } catch (_) {
      // Pusty stan to akceptowalny fallback.
    }
  }

  void newChat() {
    if (state.isStreaming) return;
    state = const ChatState();
  }

  Future<void> send(String text) async {
    if (state.isStreaming || text.trim().isEmpty) return;

    final target = await ref.read(chatTargetProvider.future);
    if (target == null) {
      state = state.copyWith(error: 'Brak aktywnego serwera.');
      return;
    }

    final repo = ref.read(messageRepositoryProvider);

    var chatId = state.chatId;
    chatId ??= await repo.createChat();

    final userId = await repo.appendMessage(
      chatId: chatId,
      role: 'user',
      content: text.trim(),
      parentId: state.lastMessageId,
    );

    final history = [...state.messages, ChatMessage('user', text.trim())];
    state = state.copyWith(
      chatId: chatId,
      lastMessageId: userId,
      messages: history,
      isStreaming: true,
      streamingContent: '',
      streamingReasoning: '',
      clearError: true,
    );

    _cancelToken = CancelToken();
    final chatApi = ref.read(chatRepositoryProvider);

    try {
      await for (final chunk in chatApi.streamCompletion(
        baseUrl: target.baseUrl,
        apiKey: target.apiKey,
        model: target.model,
        messages: history,
        cancelToken: _cancelToken,
      )) {
        if (chunk.done) break;
        state = state.copyWith(
          streamingContent: chunk.contentDelta != null
              ? state.streamingContent + chunk.contentDelta!
              : null,
          streamingReasoning: chunk.reasoningDelta != null
              ? state.streamingReasoning + chunk.reasoningDelta!
              : null,
        );
      }
      await _commitAssistant(
        repo,
        chatId,
        userId,
        target.model,
        isPartial: false,
      );
    } catch (e) {
      await _commitAssistant(
        repo,
        chatId,
        userId,
        target.model,
        isPartial: true,
      );
      if (e is! DioException || e.type != DioExceptionType.cancel) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  void stop() {
    _cancelToken?.cancel();
  }

  Future<void> _commitAssistant(
    MessageRepository repo,
    String chatId,
    String parentUserId,
    String model, {
    required bool isPartial,
  }) async {
    final content = state.streamingContent;
    final reasoning = state.streamingReasoning;

    if (content.isEmpty && reasoning.isEmpty) {
      state = state.copyWith(
        isStreaming: false,
        streamingContent: '',
        streamingReasoning: '',
      );
      return;
    }

    final assistantId = await repo.appendMessage(
      chatId: chatId,
      role: 'assistant',
      content: content,
      reasoning: reasoning.isEmpty ? null : reasoning,
      parentId: parentUserId,
      modelUsed: model,
      isPartial: isPartial,
    );

    final msgs = [...state.messages, ChatMessage('assistant', content)];
    state = state.copyWith(
      messages: msgs,
      lastMessageId: assistantId,
      isStreaming: false,
      streamingContent: '',
      streamingReasoning: '',
    );
  }
}
