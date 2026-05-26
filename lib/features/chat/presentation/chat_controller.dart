import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/providers.dart';
import '../../profiles/data/profile_providers.dart';
import '../data/chat_models.dart';
import '../data/chat_providers.dart';

/// Cel rozmowy — reaktywny: obserwuje aktywny profil i przelicza target.
/// StreamProvider (nie FutureProvider+.first) — eliminuje wyścig przy starcie
/// i odświeża czat gdy zmienisz aktywny serwer, bez restartu.
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
  final List<ChatMessage> messages;
  final String streamingContent;
  final String streamingReasoning;
  final bool isStreaming;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.streamingContent = '',
    this.streamingReasoning = '',
    this.isStreaming = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    String? streamingContent,
    String? streamingReasoning,
    bool? isStreaming,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
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
  ChatState build() => const ChatState();

  Future<void> send(String text) async {
    if (state.isStreaming || text.trim().isEmpty) return;

    final target = await ref.read(chatTargetProvider.future);
    if (target == null) {
      state = state.copyWith(error: 'Brak aktywnego serwera.');
      return;
    }

    final history = [...state.messages, ChatMessage('user', text.trim())];
    state = state.copyWith(
      messages: history,
      isStreaming: true,
      streamingContent: '',
      streamingReasoning: '',
      clearError: true,
    );

    _cancelToken = CancelToken();
    final repo = ref.read(chatRepositoryProvider);

    try {
      await for (final chunk in repo.streamCompletion(
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
      _finalize();
    } catch (e) {
      _finalize();
      state = state.copyWith(error: e.toString());
    }
  }

  void stop() {
    _cancelToken?.cancel();
    _finalize();
  }

  void _finalize() {
    final content = state.streamingContent;
    final msgs = [...state.messages];
    if (content.isNotEmpty) {
      msgs.add(ChatMessage('assistant', content));
    }
    state = state.copyWith(
      messages: msgs,
      streamingContent: '',
      streamingReasoning: '',
      isStreaming: false,
    );
  }
}
