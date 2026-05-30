import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/logging/log_buffer.dart';
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
    try {
      final models = await ref
          .read(apiClientProvider)
          .fetchModels(profile.baseUrl, apiKey: apiKey);
      LogBuffer().info(
        'api',
        'Fetched models for profile=${profile.name}: count=${models.length}',
      );
      return ChatTarget(
        baseUrl: profile.baseUrl,
        apiKey: apiKey,
        // models.first to fallback dla rozmów które nie mają jeszcze przypisanego
        // modelu (chats.model_id NULL). Po sesji A2 dropdown w ChatParametersSheet
        // pozwala user explicit wybrać model — wtedy state.modelId override.
        model: models.first,
        availableModels: models,
        profileName: profile.name,
      );
    } catch (e) {
      LogBuffer().error('api', 'Fetch models failed for profile=${profile.name}: $e');
      rethrow;
    }
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
    // ── A2: flagi do resetowania nullable pól na null (sentinel pattern) ──
    // Zwykle `systemPrompt ?? this.systemPrompt` nie pozwala ustawić explicit
    // null (bo null traktowane jest jako "nie zmieniaj"). Flagi pozwalają to
    // obejść gdy user czyści system prompt lub resetuje model w UI sheet.
    bool clearSystemPrompt = false,
    bool clearModelId = false,
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
      systemPrompt: clearSystemPrompt ? null : (systemPrompt ?? this.systemPrompt),
      modelId: clearModelId ? null : (modelId ?? this.modelId),
    );
  }
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);

class ChatController extends Notifier<ChatState> {
  CancelToken? _cancelToken;
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
      LogBuffer().info(
        'chat',
        'Loaded chat: id=$chatId, messages=${dbMsgs.length}, '
            'hasSystemPrompt=${chat.systemPrompt != null}, '
            'hasModel=${chat.modelId != null}',
      );
    } catch (e) {
      LogBuffer().error('chat', 'Load chat failed: id=$chatId, error=$e');
    }
  }

  void newChat() {
    if (state.isStreaming) return;
    state = const ChatState();
    LogBuffer().info('chat', 'New chat state (not yet persisted)');
  }

  Future<void> updateTitle(String title) async {
    final id = state.chatId;
    if (id == null) return;
    await ref.read(messageRepositoryProvider).updateChatTitle(id, title);
    state = state.copyWith(title: title.trim().isEmpty ? null : title.trim());
    LogBuffer().info('chat', 'Updated title: id=$id');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Sesja A2 — aktualizacja konfiguracji rozmowy z ChatParametersSheet.
  // Każda metoda: update state + persist do bazy jeśli chatId istnieje.
  // Gdy chatId == null (nowa rozmowa, jeszcze nie wysłana wiadomość) — tylko
  // state. Persist do bazy nastąpi przy pierwszym send() (patrz blok w send).
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> updateParameters(ChatParameters params) async {
    state = state.copyWith(parameters: params);
    final id = state.chatId;
    if (id != null) {
      await ref.read(messageRepositoryProvider).updateChatParameters(id, params);
    }
    LogBuffer().info(
      'param',
      'Updated parameters: chatId=$id, temperature=${params.temperature.toStringAsFixed(2)}, '
          'maxTokens=${params.maxTokens}, '
          'topP=${params.topP}, '
          'reasoning=${params.reasoningEffort?.name}',
    );
  }

  Future<void> updateSystemPrompt(String? systemPrompt) async {
    final cleaned = systemPrompt?.trim();
    final value = (cleaned == null || cleaned.isEmpty) ? null : cleaned;
    state = state.copyWith(
      systemPrompt: value,
      clearSystemPrompt: value == null,
    );
    final id = state.chatId;
    if (id != null) {
      await ref
          .read(messageRepositoryProvider)
          .updateChatSystemPrompt(id, value);
    }
    // Loggujemy że system prompt został zmieniony, ALE NIE treść (privacy).
    LogBuffer().info(
      'param',
      'Updated system prompt: chatId=$id, length=${value?.length ?? 0}',
    );
  }

  Future<void> updateModel(String? modelId) async {
    state = state.copyWith(
      modelId: modelId,
      clearModelId: modelId == null,
    );
    final id = state.chatId;
    if (id != null) {
      await ref.read(messageRepositoryProvider).updateChatModel(id, modelId);
    }
    LogBuffer().info('param', 'Updated model: chatId=$id, model=$modelId');
  }

  Future<void> send(String text) async {
    if (state.isStreaming || text.trim().isEmpty) return;

    final target = await ref.read(chatTargetProvider.future);
    if (target == null) {
      LogBuffer().warn('chat', 'Send aborted: no active server');
      state = state.copyWith(error: 'Brak aktywnego serwera.');
      return;
    }

    final repo = ref.read(messageRepositoryProvider);

    final wasNewChat = state.chatId == null;
    var chatId = state.chatId;
    chatId ??= await repo.createChat();

    // Jeśli rozmowa właśnie utworzona przez send(), persist konfigurację
    // ustawioną w state PRZED wysłaniem (user mógł otworzyć ChatParametersSheet
    // dla nowej rozmowy, zmienić parametry, zamknąć sheet, potem wysłać).
    // Bez tego state-level config byłby zignorowany przy persistance.
    if (wasNewChat) {
      LogBuffer().info('chat', 'Created new chat: id=$chatId');
      if (state.parameters != const ChatParameters()) {
        await repo.updateChatParameters(chatId, state.parameters);
      }
      if (state.systemPrompt != null && state.systemPrompt!.isNotEmpty) {
        await repo.updateChatSystemPrompt(chatId, state.systemPrompt);
      }
      if (state.modelId != null) {
        await repo.updateChatModel(chatId, state.modelId);
      }
    }

    final userId = await repo.appendMessage(
      chatId: chatId,
      role: 'user',
      content: text.trim(),
      parentId: state.lastMessageId,
      parameters: state.parameters,
    );
    final chat = await repo.getChat(chatId);

    final newUserMsg = ChatMessage('user', text.trim());
    final stateMessages = [...state.messages, newUserMsg];

    final systemPrompt = chat?.systemPrompt;
    final apiMessages = <ChatMessage>[
      if (systemPrompt != null && systemPrompt.isNotEmpty)
        ChatMessage('system', systemPrompt),
      ...stateMessages,
    ];

    final modelToUse = chat?.modelId ?? target.model;

    // Loggujemy wysyłkę — metadata bez treści (length zamiast content).
    LogBuffer().info(
      'chat',
      'Send: chatId=$chatId, model=$modelToUse, '
          'historyCount=${apiMessages.length}, '
          'lastUserLength=${text.trim().length}',
    );

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
    final sendStart = DateTime.now();

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
      await _commitAssistant(
        repo,
        chatId,
        userId,
        modelToUse,
        parameters: state.parameters,
        isPartial: _wasStopped,
      );
      final duration = DateTime.now().difference(sendStart).inMilliseconds;
      LogBuffer().info(
        'chat',
        'Response complete: chatId=$chatId, duration=${duration}ms, '
            'contentLength=${state.streamingContent.length}, '
            'reasoningLength=${state.streamingReasoning.length}, '
            'partial=$_wasStopped',
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
      LogBuffer().error('chat', 'Send error: chatId=$chatId, error=$e');
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
      LogBuffer().warn('chat', 'Continue aborted: no active server');
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

    LogBuffer().info('chat', 'Continue last partial: chatId=$chatId');

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
      LogBuffer().info('chat', 'Continue complete: chatId=$chatId');
    } catch (e) {
      await _commitContinuation(repo, partialId);
      LogBuffer().error('chat', 'Continue error: chatId=$chatId, error=$e');
      state = state.copyWith(error: e.toString());
    }
  }

  void stop() {
    _wasStopped = true;
    _cancelToken?.cancel();
    LogBuffer().info('chat', 'Stop requested');
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
