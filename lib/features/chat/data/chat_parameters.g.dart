// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_parameters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatParameters _$ChatParametersFromJson(Map<String, dynamic> json) =>
    _ChatParameters(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.8,
      topP: (json['top_p'] as num?)?.toDouble(),
      topK: (json['top_k'] as num?)?.toInt(),
      minP: (json['min_p'] as num?)?.toDouble(),
      maxTokens: (json['max_tokens'] as num?)?.toInt(),
      repeatPenalty: (json['repeat_penalty'] as num?)?.toDouble() ?? 1.1,
      frequencyPenalty: (json['frequency_penalty'] as num?)?.toDouble() ?? 0.0,
      presencePenalty: (json['presence_penalty'] as num?)?.toDouble() ?? 0.0,
      stop:
          (json['stop'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      seed: (json['seed'] as num?)?.toInt(),
      reasoningEffort: $enumDecodeNullable(
        _$ReasoningEffortEnumMap,
        json['reasoning_effort'],
      ),
      draftModel: json['draft_model'] as String?,
    );

Map<String, dynamic> _$ChatParametersToJson(_ChatParameters instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'top_p': instance.topP,
      'top_k': instance.topK,
      'min_p': instance.minP,
      'max_tokens': instance.maxTokens,
      'repeat_penalty': instance.repeatPenalty,
      'frequency_penalty': instance.frequencyPenalty,
      'presence_penalty': instance.presencePenalty,
      'stop': instance.stop,
      'seed': instance.seed,
      'reasoning_effort': _$ReasoningEffortEnumMap[instance.reasoningEffort],
      'draft_model': instance.draftModel,
    };

const _$ReasoningEffortEnumMap = {
  ReasoningEffort.low: 'low',
  ReasoningEffort.medium: 'medium',
  ReasoningEffort.high: 'high',
};
