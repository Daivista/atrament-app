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

/// Cel dla wysyłki: aktywny profil + jego rozwiązany domyślny model + pełna
/// lista modeli udostępnionych przez `/v1/models`. Lista służy dropdownowi
/// w ChatParametersSheet — user może wybrać model per rozmowa, zapisywany
/// do `chats.model_id` (sesja A2). Gdy chat nie ma `model_id`, fallback to
/// `model` (= `availableModels.first`).
class ChatTarget {
  final String baseUrl;
  final String? apiKey;
  final String model;
  final List<String> availableModels;
  final String profileName;
  const ChatTarget({
    required this.baseUrl,
    this.apiKey,
    required this.model,
    required this.availableModels,
    required this.profileName,
  });
}
