import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/providers.dart';
import '../../profiles/data/profile_providers.dart';
import '../data/chat_models.dart';
import '../data/chat_parameters.dart';
import '../data/chat_providers.dart';
import '../data/message_repository.dart';

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
      // models.first to dziś hardcoded fallback. Rozmowa może mieć własny
      // chats.model_id — wtedy ChatController preferuje ten nad target.model
      // (sesja A1). Tracked TODO: ChatTarget powinien wystawić full models list
      // dla dropdown UI w A2.
      model: models.first,
      profileName: profile.name,
    );
  });
});

class ChatState {
  final String? chatId;
  final String? lastMessageId;
  final String? title;
  final List<ChatMessage> messages;
  final String streamingContent;
  final String streamingReasoning;
  final bool isStreaming;
  final String? error;
  // ── Sesja A1: parametry rozmowy, system prompt, wybrany model ──
  final ChatParameters parameters;
  final String? systemPrompt;
  final String? modelId; // null = użyj target.model (models.first)

  const ChatState({
    this.chatId,
    this.lastMessageId,
    this.title,
    this.messages = const [],
    this.streamingContent = '',
    this.streamingReasoning = '',
    this.isStreaming = false,
    this.error,
    this.parameters = const ChatParameters(),
    this.systemPrompt,
    this.modelId,
  });

  ChatState copyWith({
    String? chatId,
    String? lastMessageId,
    String? title,
    List<ChatMessage>? messages,
    String? streamingContent,
    String? streamingReasoning,
    bool? isStreaming,
    String? error,
    bool clearError = false,
    ChatParameters? parameters,
    String? systemPrompt,
    String? modelId,
  }) {
    return ChatState(
      chatId: chatId ?? this.chatId,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      streamingContent: streamingContent ?? this.streamingContent,
      streamingReasoning: streamingReasoning ?? this.streamingReasoning,
      isStreaming: isStreaming ?? this.isStreaming,
      error: clearError ? null : (error ?? this.error),
      parameters: parameters ?? this.parameters,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      modelId: modelId ?? this.modelId,
    );
  }
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);

class ChatController extends Notifier<ChatState> {
  CancelToken? _cancelToken;
  // Flaga: user nacisnął Stop. Repo połyka cancel cicho (nie rzuca), więc bez
  // tej flagi nie odróżnimy "normalne done" od "anulowano" — i partial nie
  // dostałby flagi isPartial. Resetowana na false na początku każdego send/continueLast.
  bool _wasStopped = false;

  @override
  ChatState build() => const ChatState();

  Future<void> loadChat(String chatId) async {
    if (state.isStreaming) return;
    state = const ChatState();
    try {
      final repo = ref.read(messageRepositoryProvider);
      final chat = await repo.getChat(chatId);
      if (chat == null) return;
      final dbMsgs = await repo.getMessages(chatId);
      final params = await repo.getChatParameters(chatId);
      state = state.copyWith(
        chatId: chat.id,
        lastMessageId: chat.activeLeafMessageId,
        title: chat.title,
        messages: dbMsgs
            .map(
              (m) =>
                  ChatMessage(m.role, m.content ?? '', isPartial: m.isPartial),
            )
            .toList(),
        parameters: params,
        systemPrompt: chat.systemPrompt,
        modelId: chat.modelId,
      );
    } catch (_) {}
  }

  void newChat() {
    if (state.isStreaming) return;
    state = const ChatState();
  }

  Future<void> updateTitle(String title) async {
    final id = state.chatId;
    if (id == null) return;
    await ref.read(messageRepositoryProvider).updateChatTitle(id, title);
    state = state.copyWith(title: title.trim().isEmpty ? null : title.trim());
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
      parameters: state.parameters,
    );
    final chat = await repo.getChat(chatId);

    // State.messages (UI): bez system message — user go nie widzi w bańkach.
    final newUserMsg = ChatMessage('user', text.trim());
    final stateMessages = [...state.messages, newUserMsg];

    // API messages: dodaj system na początku jeśli chat ma system_prompt.
    final systemPrompt = chat?.systemPrompt;
    final apiMessages = <ChatMessage>[
      if (systemPrompt != null && systemPrompt.isNotEmpty)
        ChatMessage('system', systemPrompt),
      ...stateMessages,
    ];

    // Preferuj chat.model_id (jeśli ustawiony przez UI A2), fallback do
    // dzisiejszego models.first z target.
    final modelToUse = chat?.modelId ?? target.model;

    state = state.copyWith(
      chatId: chatId,
      lastMessageId: userId,
      title: chat?.title,
      messages: stateMessages,
      isStreaming: true,
      streamingContent: '',
      streamingReasoning: '',
      clearError: true,
    );

    _cancelToken = CancelToken();
    _wasStopped = false;
    final chatApi = ref.read(chatRepositoryProvider);

    try {
      await for (final chunk in chatApi.streamCompletion(
        baseUrl: target.baseUrl,
        apiKey: target.apiKey,
        model: modelToUse,
        messages: apiMessages,
        parameters: state.parameters,
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
      // Po wyjściu z pętli sprawdzamy CZY user anulował.
      // Repo połyka cancel cicho, więc tutaj rozróżniamy.
      await _commitAssistant(
        repo,
        chatId,
        userId,
        modelToUse,
        parameters: state.parameters,
        isPartial: _wasStopped,
      );
    } catch (e) {
      await _commitAssistant(
        repo,
        chatId,
        userId,
        modelToUse,
        parameters: state.parameters,
        isPartial: true,
      );
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> continueLast() async {
    if (state.isStreaming) return;
    if (state.messages.isEmpty) return;
    final last = state.messages.last;
    if (!last.isPartial || last.role != 'assistant') return;

    final target = await ref.read(chatTargetProvider.future);
    if (target == null) {
      state = state.copyWith(error: 'Brak aktywnego serwera.');
      return;
    }

    final chatId = state.chatId;
    final partialId = state.lastMessageId;
    if (chatId == null || partialId == null) return;

    final repo = ref.read(messageRepositoryProvider);
    final chat = await repo.getChat(chatId);
    final systemPrompt = chat?.systemPrompt;
    final modelToUse = chat?.modelId ?? target.model;

    final continueMsg = ChatMessage(
      'user',
      'Kontynuuj poprzednią odpowiedź od miejsca w którym przerwałeś. '
          'Twoja częściowa odpowiedź: "${last.content}". '
          'Dokończ ją naturalnie, nie powtarzaj początku.',
    );
    final historyForApi = <ChatMessage>[
      if (systemPrompt != null && systemPrompt.isNotEmpty)
        ChatMessage('system', systemPrompt),
      ...state.messages,
      continueMsg,
    ];

    state = state.copyWith(
      isStreaming: true,
      streamingContent: '',
      streamingReasoning: '',
      clearError: true,
    );

    _cancelToken = CancelToken();
    _wasStopped = false;
    final chatApi = ref.read(chatRepositoryProvider);

    try {
      await for (final chunk in chatApi.streamCompletion(
        baseUrl: target.baseUrl,
        apiKey: target.apiKey,
        model: modelToUse,
        messages: historyForApi,
        parameters: state.parameters,
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
      await _commitContinuation(repo, partialId);
    } catch (e) {
      await _commitContinuation(repo, partialId);
      state = state.copyWith(error: e.toString());
    }
  }

  void stop() {
    _wasStopped = true;
    _cancelToken?.cancel();
  }

  Future<void> _commitAssistant(
    MessageRepository repo,
    String chatId,
    String parentUserId,
    String model, {
    required bool isPartial,
    required ChatParameters parameters,
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
      parameters: parameters,
      isPartial: isPartial,
    );
    final msgs = [
      ...state.messages,
      ChatMessage('assistant', content, isPartial: isPartial),
    ];
    state = state.copyWith(
      messages: msgs,
      lastMessageId: assistantId,
      isStreaming: false,
      streamingContent: '',
      streamingReasoning: '',
    );
  }

  Future<void> _commitContinuation(
    MessageRepository repo,
    String partialId,
  ) async {
    final addition = state.streamingContent;
    final additionReasoning = state.streamingReasoning;
    if (addition.isEmpty && additionReasoning.isEmpty) {
      state = state.copyWith(
        isStreaming: false,
        streamingContent: '',
        streamingReasoning: '',
      );
      return;
    }
    await repo.appendContinuation(
      partialId,
      addition,
      additionalReasoning: additionReasoning,
    );
    final msgs = [...state.messages];
    final last = msgs.removeLast();
    // Jeśli user znowu nacisnął Stop podczas resume — zostaw partial=true,
    // bo appendContinuation z bazy zawsze ustawia 0; UI dostanie poprawną flagę,
    // baza zostanie zaktualizowana przy następnym dokończeniu lub edycji.
    final stillPartial = _wasStopped;
    msgs.add(
      ChatMessage(last.role, last.content + addition, isPartial: stillPartial),
    );
    state = state.copyWith(
      messages: msgs,
      isStreaming: false,
      streamingContent: '',
      streamingReasoning: '',
    );
  }
}
