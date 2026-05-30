/// Data models dla rozmowy z LLM.
///
/// Sesja F (reasoning UI dopracowanie): ChatMessage zyskuje optional
/// `reasoning` field żeby surface'ować chain-of-thought modeli rozumujących
/// (Gemma o-series, DeepSeek, QwQ) zarówno podczas streaming jak i dla
/// historic messages załadowanych z DB. Wcześniej reasoning był ephemeral —
/// widoczny tylko przez `chat.streamingReasoning` podczas generowania,
/// ginący po commit do state.
library;

class ChatMessage {
  final String role;
  final String content;

  /// Chain-of-thought modeli rozumujących. Null dla wiadomości user/system
  /// oraz dla odpowiedzi z modeli nie-rozumujących (gpt-4o, llama).
  final String? reasoning;

  /// True gdy odpowiedź była przerwana przez Stop lub błąd sieci — banner
  /// "Odpowiedź przerwana" + button "Kontynuuj" pokazane w chat screen.
  final bool isPartial;

  const ChatMessage(
    this.role,
    this.content, {
    this.reasoning,
    this.isPartial = false,
  });

  /// Serializacja do API request (OpenAI-compatible /v1/chat/completions).
  /// Zawiera tylko `role` + `content` — reasoning NIE jest wysyłany do
  /// modelu jako input (jest per-message historic field, nie kontekst dla
  /// kolejnego generowania). LM Studio i Ollama ignorują pola które nie
  /// są w schemacie OpenAI Chat, więc dodatkowe pola w jsonie byłyby
  /// bezpieczne, ale niepotrzebne.
  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Pojedynczy chunk delta dla streamingu odpowiedzi z chat repository.
/// content/reasoning są nullable bo nie każdy chunk ma oba — Gemma o najpierw
/// produkuje reasoning, potem content; gpt-4o produkuje tylko content.
/// done=true to terminating chunk (SSE [DONE] marker).
class ChatChunk {
  final String? contentDelta;
  final String? reasoningDelta;
  final bool done;
  const ChatChunk({this.contentDelta, this.reasoningDelta, this.done = false});
}

/// Cel dla wysyłki: aktywny profil + jego rozwiązany domyślny model + pełna
/// lista modeli udostępnionych przez `/v1/models`. Lista służy dropdownowi
/// w ChatParametersSheet — user może wybrać model per rozmowa, zapisywany
/// do `chats.model_id` (Sesja A2). Gdy chat nie ma `model_id`, fallback to
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
