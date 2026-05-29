import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_parameters.freezed.dart';
part 'chat_parameters.g.dart';

/// Poziom "wysiłku rozumowania" dla modeli rozumujących (GPT-OSS,
/// DeepSeek-R1, Qwen3-Thinking). API LM Studio przyjmuje to jako
/// zagnieżdżone `reasoning: { effort: '<low|medium|high>' }`,
/// natomiast `ChatParameters.toJson()` produkuje płaskie
/// `reasoning_effort: '<low|medium|high>'`. Transformacja do
/// zagnieżdżonej formy odbywa się w `chat_repository.streamCompletion`
/// tuż przed wysłaniem payloadu — żeby ChatParameters miało jedną,
/// płaską serializację używaną i do bazy (JSON-blob) i do API.
enum ReasoningEffort { low, medium, high }

/// Parametry inference modelu LLM. Serializowane do/z JSON-blob w
/// polach `chats.parameters_json` (aktywny override dla rozmowy) oraz
/// `messages.parameters_json` (snapshot dla audytu — zapisywany przy
/// każdej wiadomości, żeby można było dokładnie odtworzyć z czym
/// wysłano każdy request).
///
/// Konwencja JSON: wszystkie multi-word pola mają `@JsonKey` z
/// `snake_case`, żeby `toJson()` generowało payload zgodny z API
/// OpenAI-compatible (LM Studio). Jedna mapa serializuje do bazy
/// I do API — bez podwójnej konwersji.
///
/// **KRYTYCZNA PUŁAPKA LM STUDIO** (manifest sekcja 6, linia 240):
/// aplikacja MUSI wysyłać wszystkie te parametry jawnie w każdym
/// żądaniu, nie polegać na "preset" po stronie LM Studio. Jeśli
/// payload nie zawiera np. `temperature`, LM Studio użyje wartości
/// z presetu w GUI — nie z `ChatParameters()` defaults aplikacji.
@freezed
abstract class ChatParameters with _$ChatParameters {
  const factory ChatParameters({
    @Default(0.8) double temperature,
    @JsonKey(name: 'top_p') double? topP,
    @JsonKey(name: 'top_k') int? topK,
    @JsonKey(name: 'min_p') double? minP,
    @JsonKey(name: 'max_tokens') int? maxTokens,
    @JsonKey(name: 'repeat_penalty') @Default(1.1) double repeatPenalty,
    @JsonKey(name: 'frequency_penalty') @Default(0.0) double frequencyPenalty,
    @JsonKey(name: 'presence_penalty') @Default(0.0) double presencePenalty,
    @Default(<String>[]) List<String> stop,
    int? seed,
    @JsonKey(name: 'reasoning_effort') ReasoningEffort? reasoningEffort,
    @JsonKey(name: 'draft_model') String? draftModel,
  }) = _ChatParameters;

  factory ChatParameters.fromJson(Map<String, dynamic> json) =>
      _$ChatParametersFromJson(json);
}
