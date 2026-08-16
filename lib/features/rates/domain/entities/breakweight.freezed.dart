// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'breakweight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Breakweight {

 String get min; String get max;
/// Create a copy of Breakweight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BreakweightCopyWith<Breakweight> get copyWith => _$BreakweightCopyWithImpl<Breakweight>(this as Breakweight, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Breakweight&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}


@override
int get hashCode => Object.hash(runtimeType,min,max);

@override
String toString() {
  return 'Breakweight(min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class $BreakweightCopyWith<$Res>  {
  factory $BreakweightCopyWith(Breakweight value, $Res Function(Breakweight) _then) = _$BreakweightCopyWithImpl;
@useResult
$Res call({
 String min, String max
});




}
/// @nodoc
class _$BreakweightCopyWithImpl<$Res>
    implements $BreakweightCopyWith<$Res> {
  _$BreakweightCopyWithImpl(this._self, this._then);

  final Breakweight _self;
  final $Res Function(Breakweight) _then;

/// Create a copy of Breakweight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? min = null,Object? max = null,}) {
  return _then(_self.copyWith(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as String,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Breakweight].
extension BreakweightPatterns on Breakweight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Breakweight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Breakweight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Breakweight value)  $default,){
final _that = this;
switch (_that) {
case _Breakweight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Breakweight value)?  $default,){
final _that = this;
switch (_that) {
case _Breakweight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String min,  String max)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Breakweight() when $default != null:
return $default(_that.min,_that.max);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String min,  String max)  $default,) {final _that = this;
switch (_that) {
case _Breakweight():
return $default(_that.min,_that.max);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String min,  String max)?  $default,) {final _that = this;
switch (_that) {
case _Breakweight() when $default != null:
return $default(_that.min,_that.max);case _:
  return null;

}
}

}

/// @nodoc


class _Breakweight implements Breakweight {
  const _Breakweight({this.min = '1', this.max = ''});
  

@override@JsonKey() final  String min;
@override@JsonKey() final  String max;

/// Create a copy of Breakweight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BreakweightCopyWith<_Breakweight> get copyWith => __$BreakweightCopyWithImpl<_Breakweight>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Breakweight&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}


@override
int get hashCode => Object.hash(runtimeType,min,max);

@override
String toString() {
  return 'Breakweight(min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class _$BreakweightCopyWith<$Res> implements $BreakweightCopyWith<$Res> {
  factory _$BreakweightCopyWith(_Breakweight value, $Res Function(_Breakweight) _then) = __$BreakweightCopyWithImpl;
@override @useResult
$Res call({
 String min, String max
});




}
/// @nodoc
class __$BreakweightCopyWithImpl<$Res>
    implements _$BreakweightCopyWith<$Res> {
  __$BreakweightCopyWithImpl(this._self, this._then);

  final _Breakweight _self;
  final $Res Function(_Breakweight) _then;

/// Create a copy of Breakweight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? min = null,Object? max = null,}) {
  return _then(_Breakweight(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as String,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
