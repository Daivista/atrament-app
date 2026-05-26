/// Wiadomość w formacie OpenAI messages[].
class ChatMessage {
  final String role; // 'user' | 'assistant' | 'system'
  final String content;
  const ChatMessage(this.role, this.content);
  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Fragment odpowiedzi ze streamingu (content i reasoning rozdzielone).
class ChatChunk {
  final String? contentDelta;
  final String? reasoningDelta;
  final bool done;
  const ChatChunk({this.contentDelta, this.reasoningDelta, this.done = false});
}

/// Cel rozmowy: dane aktywnego serwera + wybrany model.
class ChatTarget {
  final String baseUrl;
  final String? apiKey;
  final String model;
  final String profileName;
  const ChatTarget({
    required this.baseUrl,
    this.apiKey,
    required this.model,
    required this.profileName,
  });
}
