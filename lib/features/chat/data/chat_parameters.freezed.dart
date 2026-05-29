// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_parameters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatParameters {

 double get temperature;@JsonKey(name: 'top_p') double? get topP;@JsonKey(name: 'top_k') int? get topK;@JsonKey(name: 'min_p') double? get minP;@JsonKey(name: 'max_tokens') int? get maxTokens;@JsonKey(name: 'repeat_penalty') double get repeatPenalty;@JsonKey(name: 'frequency_penalty') double get frequencyPenalty;@JsonKey(name: 'presence_penalty') double get presencePenalty; List<String> get stop; int? get seed;@JsonKey(name: 'reasoning_effort') ReasoningEffort? get reasoningEffort;@JsonKey(name: 'draft_model') String? get draftModel;
/// Create a copy of ChatParameters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatParametersCopyWith<ChatParameters> get copyWith => _$ChatParametersCopyWithImpl<ChatParameters>(this as ChatParameters, _$identity);

  /// Serializes this ChatParameters to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatParameters&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.topP, topP) || other.topP == topP)&&(identical(other.topK, topK) || other.topK == topK)&&(identical(other.minP, minP) || other.minP == minP)&&(identical(other.maxTokens, maxTokens) || other.maxTokens == maxTokens)&&(identical(other.repeatPenalty, repeatPenalty) || other.repeatPenalty == repeatPenalty)&&(identical(other.frequencyPenalty, frequencyPenalty) || other.frequencyPenalty == frequencyPenalty)&&(identical(other.presencePenalty, presencePenalty) || other.presencePenalty == presencePenalty)&&const DeepCollectionEquality().equals(other.stop, stop)&&(identical(other.seed, seed) || other.seed == seed)&&(identical(other.reasoningEffort, reasoningEffort) || other.reasoningEffort == reasoningEffort)&&(identical(other.draftModel, draftModel) || other.draftModel == draftModel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,temperature,topP,topK,minP,maxTokens,repeatPenalty,frequencyPenalty,presencePenalty,const DeepCollectionEquality().hash(stop),seed,reasoningEffort,draftModel);

@override
String toString() {
  return 'ChatParameters(temperature: $temperature, topP: $topP, topK: $topK, minP: $minP, maxTokens: $maxTokens, repeatPenalty: $repeatPenalty, frequencyPenalty: $frequencyPenalty, presencePenalty: $presencePenalty, stop: $stop, seed: $seed, reasoningEffort: $reasoningEffort, draftModel: $draftModel)';
}


}

/// @nodoc
abstract mixin class $ChatParametersCopyWith<$Res>  {
  factory $ChatParametersCopyWith(ChatParameters value, $Res Function(ChatParameters) _then) = _$ChatParametersCopyWithImpl;
@useResult
$Res call({
 double temperature,@JsonKey(name: 'top_p') double? topP,@JsonKey(name: 'top_k') int? topK,@JsonKey(name: 'min_p') double? minP,@JsonKey(name: 'max_tokens') int? maxTokens,@JsonKey(name: 'repeat_penalty') double repeatPenalty,@JsonKey(name: 'frequency_penalty') double frequencyPenalty,@JsonKey(name: 'presence_penalty') double presencePenalty, List<String> stop, int? seed,@JsonKey(name: 'reasoning_effort') ReasoningEffort? reasoningEffort,@JsonKey(name: 'draft_model') String? draftModel
});




}
/// @nodoc
class _$ChatParametersCopyWithImpl<$Res>
    implements $ChatParametersCopyWith<$Res> {
  _$ChatParametersCopyWithImpl(this._self, this._then);

  final ChatParameters _self;
  final $Res Function(ChatParameters) _then;

/// Create a copy of ChatParameters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? temperature = null,Object? topP = freezed,Object? topK = freezed,Object? minP = freezed,Object? maxTokens = freezed,Object? repeatPenalty = null,Object? frequencyPenalty = null,Object? presencePenalty = null,Object? stop = null,Object? seed = freezed,Object? reasoningEffort = freezed,Object? draftModel = freezed,}) {
  return _then(_self.copyWith(
temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,topP: freezed == topP ? _self.topP : topP // ignore: cast_nullable_to_non_nullable
as double?,topK: freezed == topK ? _self.topK : topK // ignore: cast_nullable_to_non_nullable
as int?,minP: freezed == minP ? _self.minP : minP // ignore: cast_nullable_to_non_nullable
as double?,maxTokens: freezed == maxTokens ? _self.maxTokens : maxTokens // ignore: cast_nullable_to_non_nullable
as int?,repeatPenalty: null == repeatPenalty ? _self.repeatPenalty : repeatPenalty // ignore: cast_nullable_to_non_nullable
as double,frequencyPenalty: null == frequencyPenalty ? _self.frequencyPenalty : frequencyPenalty // ignore: cast_nullable_to_non_nullable
as double,presencePenalty: null == presencePenalty ? _self.presencePenalty : presencePenalty // ignore: cast_nullable_to_non_nullable
as double,stop: null == stop ? _self.stop : stop // ignore: cast_nullable_to_non_nullable
as List<String>,seed: freezed == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int?,reasoningEffort: freezed == reasoningEffort ? _self.reasoningEffort : reasoningEffort // ignore: cast_nullable_to_non_nullable
as ReasoningEffort?,draftModel: freezed == draftModel ? _self.draftModel : draftModel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatParameters].
extension ChatParametersPatterns on ChatParameters {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatParameters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatParameters() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatParameters value)  $default,){
final _that = this;
switch (_that) {
case _ChatParameters():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatParameters value)?  $default,){
final _that = this;
switch (_that) {
case _ChatParameters() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double temperature, @JsonKey(name: 'top_p')  double? topP, @JsonKey(name: 'top_k')  int? topK, @JsonKey(name: 'min_p')  double? minP, @JsonKey(name: 'max_tokens')  int? maxTokens, @JsonKey(name: 'repeat_penalty')  double repeatPenalty, @JsonKey(name: 'frequency_penalty')  double frequencyPenalty, @JsonKey(name: 'presence_penalty')  double presencePenalty,  List<String> stop,  int? seed, @JsonKey(name: 'reasoning_effort')  ReasoningEffort? reasoningEffort, @JsonKey(name: 'draft_model')  String? draftModel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatParameters() when $default != null:
return $default(_that.temperature,_that.topP,_that.topK,_that.minP,_that.maxTokens,_that.repeatPenalty,_that.frequencyPenalty,_that.presencePenalty,_that.stop,_that.seed,_that.reasoningEffort,_that.draftModel);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double temperature, @JsonKey(name: 'top_p')  double? topP, @JsonKey(name: 'top_k')  int? topK, @JsonKey(name: 'min_p')  double? minP, @JsonKey(name: 'max_tokens')  int? maxTokens, @JsonKey(name: 'repeat_penalty')  double repeatPenalty, @JsonKey(name: 'frequency_penalty')  double frequencyPenalty, @JsonKey(name: 'presence_penalty')  double presencePenalty,  List<String> stop,  int? seed, @JsonKey(name: 'reasoning_effort')  ReasoningEffort? reasoningEffort, @JsonKey(name: 'draft_model')  String? draftModel)  $default,) {final _that = this;
switch (_that) {
case _ChatParameters():
return $default(_that.temperature,_that.topP,_that.topK,_that.minP,_that.maxTokens,_that.repeatPenalty,_that.frequencyPenalty,_that.presencePenalty,_that.stop,_that.seed,_that.reasoningEffort,_that.draftModel);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double temperature, @JsonKey(name: 'top_p')  double? topP, @JsonKey(name: 'top_k')  int? topK, @JsonKey(name: 'min_p')  double? minP, @JsonKey(name: 'max_tokens')  int? maxTokens, @JsonKey(name: 'repeat_penalty')  double repeatPenalty, @JsonKey(name: 'frequency_penalty')  double frequencyPenalty, @JsonKey(name: 'presence_penalty')  double presencePenalty,  List<String> stop,  int? seed, @JsonKey(name: 'reasoning_effort')  ReasoningEffort? reasoningEffort, @JsonKey(name: 'draft_model')  String? draftModel)?  $default,) {final _that = this;
switch (_that) {
case _ChatParameters() when $default != null:
return $default(_that.temperature,_that.topP,_that.topK,_that.minP,_that.maxTokens,_that.repeatPenalty,_that.frequencyPenalty,_that.presencePenalty,_that.stop,_that.seed,_that.reasoningEffort,_that.draftModel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatParameters implements ChatParameters {
  const _ChatParameters({this.temperature = 0.8, @JsonKey(name: 'top_p') this.topP, @JsonKey(name: 'top_k') this.topK, @JsonKey(name: 'min_p') this.minP, @JsonKey(name: 'max_tokens') this.maxTokens, @JsonKey(name: 'repeat_penalty') this.repeatPenalty = 1.1, @JsonKey(name: 'frequency_penalty') this.frequencyPenalty = 0.0, @JsonKey(name: 'presence_penalty') this.presencePenalty = 0.0, final  List<String> stop = const <String>[], this.seed, @JsonKey(name: 'reasoning_effort') this.reasoningEffort, @JsonKey(name: 'draft_model') this.draftModel}): _stop = stop;
  factory _ChatParameters.fromJson(Map<String, dynamic> json) => _$ChatParametersFromJson(json);

@override@JsonKey() final  double temperature;
@override@JsonKey(name: 'top_p') final  double? topP;
@override@JsonKey(name: 'top_k') final  int? topK;
@override@JsonKey(name: 'min_p') final  double? minP;
@override@JsonKey(name: 'max_tokens') final  int? maxTokens;
@override@JsonKey(name: 'repeat_penalty') final  double repeatPenalty;
@override@JsonKey(name: 'frequency_penalty') final  double frequencyPenalty;
@override@JsonKey(name: 'presence_penalty') final  double presencePenalty;
 final  List<String> _stop;
@override@JsonKey() List<String> get stop {
  if (_stop is EqualUnmodifiableListView) return _stop;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stop);
}

@override final  int? seed;
@override@JsonKey(name: 'reasoning_effort') final  ReasoningEffort? reasoningEffort;
@override@JsonKey(name: 'draft_model') final  String? draftModel;

/// Create a copy of ChatParameters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatParametersCopyWith<_ChatParameters> get copyWith => __$ChatParametersCopyWithImpl<_ChatParameters>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatParametersToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatParameters&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.topP, topP) || other.topP == topP)&&(identical(other.topK, topK) || other.topK == topK)&&(identical(other.minP, minP) || other.minP == minP)&&(identical(other.maxTokens, maxTokens) || other.maxTokens == maxTokens)&&(identical(other.repeatPenalty, repeatPenalty) || other.repeatPenalty == repeatPenalty)&&(identical(other.frequencyPenalty, frequencyPenalty) || other.frequencyPenalty == frequencyPenalty)&&(identical(other.presencePenalty, presencePenalty) || other.presencePenalty == presencePenalty)&&const DeepCollectionEquality().equals(other._stop, _stop)&&(identical(other.seed, seed) || other.seed == seed)&&(identical(other.reasoningEffort, reasoningEffort) || other.reasoningEffort == reasoningEffort)&&(identical(other.draftModel, draftModel) || other.draftModel == draftModel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,temperature,topP,topK,minP,maxTokens,repeatPenalty,frequencyPenalty,presencePenalty,const DeepCollectionEquality().hash(_stop),seed,reasoningEffort,draftModel);

@override
String toString() {
  return 'ChatParameters(temperature: $temperature, topP: $topP, topK: $topK, minP: $minP, maxTokens: $maxTokens, repeatPenalty: $repeatPenalty, frequencyPenalty: $frequencyPenalty, presencePenalty: $presencePenalty, stop: $stop, seed: $seed, reasoningEffort: $reasoningEffort, draftModel: $draftModel)';
}


}

/// @nodoc
abstract mixin class _$ChatParametersCopyWith<$Res> implements $ChatParametersCopyWith<$Res> {
  factory _$ChatParametersCopyWith(_ChatParameters value, $Res Function(_ChatParameters) _then) = __$ChatParametersCopyWithImpl;
@override @useResult
$Res call({
 double temperature,@JsonKey(name: 'top_p') double? topP,@JsonKey(name: 'top_k') int? topK,@JsonKey(name: 'min_p') double? minP,@JsonKey(name: 'max_tokens') int? maxTokens,@JsonKey(name: 'repeat_penalty') double repeatPenalty,@JsonKey(name: 'frequency_penalty') double frequencyPenalty,@JsonKey(name: 'presence_penalty') double presencePenalty, List<String> stop, int? seed,@JsonKey(name: 'reasoning_effort') ReasoningEffort? reasoningEffort,@JsonKey(name: 'draft_model') String? draftModel
});




}
/// @nodoc
class __$ChatParametersCopyWithImpl<$Res>
    implements _$ChatParametersCopyWith<$Res> {
  __$ChatParametersCopyWithImpl(this._self, this._then);

  final _ChatParameters _self;
  final $Res Function(_ChatParameters) _then;

/// Create a copy of ChatParameters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? temperature = null,Object? topP = freezed,Object? topK = freezed,Object? minP = freezed,Object? maxTokens = freezed,Object? repeatPenalty = null,Object? frequencyPenalty = null,Object? presencePenalty = null,Object? stop = null,Object? seed = freezed,Object? reasoningEffort = freezed,Object? draftModel = freezed,}) {
  return _then(_ChatParameters(
temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,topP: freezed == topP ? _self.topP : topP // ignore: cast_nullable_to_non_nullable
as double?,topK: freezed == topK ? _self.topK : topK // ignore: cast_nullable_to_non_nullable
as int?,minP: freezed == minP ? _self.minP : minP // ignore: cast_nullable_to_non_nullable
as double?,maxTokens: freezed == maxTokens ? _self.maxTokens : maxTokens // ignore: cast_nullable_to_non_nullable
as int?,repeatPenalty: null == repeatPenalty ? _self.repeatPenalty : repeatPenalty // ignore: cast_nullable_to_non_nullable
as double,frequencyPenalty: null == frequencyPenalty ? _self.frequencyPenalty : frequencyPenalty // ignore: cast_nullable_to_non_nullable
as double,presencePenalty: null == presencePenalty ? _self.presencePenalty : presencePenalty // ignore: cast_nullable_to_non_nullable
as double,stop: null == stop ? _self._stop : stop // ignore: cast_nullable_to_non_nullable
as List<String>,seed: freezed == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int?,reasoningEffort: freezed == reasoningEffort ? _self.reasoningEffort : reasoningEffort // ignore: cast_nullable_to_non_nullable
as ReasoningEffort?,draftModel: freezed == draftModel ? _self.draftModel : draftModel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
