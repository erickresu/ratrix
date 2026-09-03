// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rate_stat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RateStat {

 String get label; String get value; String get delta; String get breakdown;
/// Create a copy of RateStat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RateStatCopyWith<RateStat> get copyWith => _$RateStatCopyWithImpl<RateStat>(this as RateStat, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RateStat&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.breakdown, breakdown) || other.breakdown == breakdown));
}


@override
int get hashCode => Object.hash(runtimeType,label,value,delta,breakdown);

@override
String toString() {
  return 'RateStat(label: $label, value: $value, delta: $delta, breakdown: $breakdown)';
}


}

/// @nodoc
abstract mixin class $RateStatCopyWith<$Res>  {
  factory $RateStatCopyWith(RateStat value, $Res Function(RateStat) _then) = _$RateStatCopyWithImpl;
@useResult
$Res call({
 String label, String value, String delta, String breakdown
});




}
/// @nodoc
class _$RateStatCopyWithImpl<$Res>
    implements $RateStatCopyWith<$Res> {
  _$RateStatCopyWithImpl(this._self, this._then);

  final RateStat _self;
  final $Res Function(RateStat) _then;

/// Create a copy of RateStat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? value = null,Object? delta = null,Object? breakdown = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as String,breakdown: null == breakdown ? _self.breakdown : breakdown // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RateStat].
extension RateStatPatterns on RateStat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RateStat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RateStat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RateStat value)  $default,){
final _that = this;
switch (_that) {
case _RateStat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RateStat value)?  $default,){
final _that = this;
switch (_that) {
case _RateStat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String value,  String delta,  String breakdown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RateStat() when $default != null:
return $default(_that.label,_that.value,_that.delta,_that.breakdown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String value,  String delta,  String breakdown)  $default,) {final _that = this;
switch (_that) {
case _RateStat():
return $default(_that.label,_that.value,_that.delta,_that.breakdown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String value,  String delta,  String breakdown)?  $default,) {final _that = this;
switch (_that) {
case _RateStat() when $default != null:
return $default(_that.label,_that.value,_that.delta,_that.breakdown);case _:
  return null;

}
}

}

/// @nodoc


class _RateStat implements RateStat {
  const _RateStat({required this.label, required this.value, required this.delta, this.breakdown = ''});
  

@override final  String label;
@override final  String value;
@override final  String delta;
@override@JsonKey() final  String breakdown;

/// Create a copy of RateStat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RateStatCopyWith<_RateStat> get copyWith => __$RateStatCopyWithImpl<_RateStat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RateStat&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.breakdown, breakdown) || other.breakdown == breakdown));
}


@override
int get hashCode => Object.hash(runtimeType,label,value,delta,breakdown);

@override
String toString() {
  return 'RateStat(label: $label, value: $value, delta: $delta, breakdown: $breakdown)';
}


}

/// @nodoc
abstract mixin class _$RateStatCopyWith<$Res> implements $RateStatCopyWith<$Res> {
  factory _$RateStatCopyWith(_RateStat value, $Res Function(_RateStat) _then) = __$RateStatCopyWithImpl;
@override @useResult
$Res call({
 String label, String value, String delta, String breakdown
});




}
/// @nodoc
class __$RateStatCopyWithImpl<$Res>
    implements _$RateStatCopyWith<$Res> {
  __$RateStatCopyWithImpl(this._self, this._then);

  final _RateStat _self;
  final $Res Function(_RateStat) _then;

/// Create a copy of RateStat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? value = null,Object? delta = null,Object? breakdown = null,}) {
  return _then(_RateStat(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as String,breakdown: null == breakdown ? _self.breakdown : breakdown // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
