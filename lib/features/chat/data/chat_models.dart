class ChatMessage {
  final String role;
  final String content;
  final bool isPartial;
  const ChatMessage(this.role, this.content, {this.isPartial = false});
  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class ChatChunk {
  final String? contentDelta;
  final String? reasoningDelta;
  final bool done;
  const ChatChunk({this.contentDelta, this.reasoningDelta, this.done = false});
}

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
