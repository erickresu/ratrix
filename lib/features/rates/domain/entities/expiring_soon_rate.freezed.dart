// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expiring_soon_rate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExpiringSoonRate {

 String get client; String get chargeCode; int get daysLeft;
/// Create a copy of ExpiringSoonRate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpiringSoonRateCopyWith<ExpiringSoonRate> get copyWith => _$ExpiringSoonRateCopyWithImpl<ExpiringSoonRate>(this as ExpiringSoonRate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpiringSoonRate&&(identical(other.client, client) || other.client == client)&&(identical(other.chargeCode, chargeCode) || other.chargeCode == chargeCode)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft));
}


@override
int get hashCode => Object.hash(runtimeType,client,chargeCode,daysLeft);

@override
String toString() {
  return 'ExpiringSoonRate(client: $client, chargeCode: $chargeCode, daysLeft: $daysLeft)';
}


}

/// @nodoc
abstract mixin class $ExpiringSoonRateCopyWith<$Res>  {
  factory $ExpiringSoonRateCopyWith(ExpiringSoonRate value, $Res Function(ExpiringSoonRate) _then) = _$ExpiringSoonRateCopyWithImpl;
@useResult
$Res call({
 String client, String chargeCode, int daysLeft
});




}
/// @nodoc
class _$ExpiringSoonRateCopyWithImpl<$Res>
    implements $ExpiringSoonRateCopyWith<$Res> {
  _$ExpiringSoonRateCopyWithImpl(this._self, this._then);

  final ExpiringSoonRate _self;
  final $Res Function(ExpiringSoonRate) _then;

/// Create a copy of ExpiringSoonRate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? client = null,Object? chargeCode = null,Object? daysLeft = null,}) {
  return _then(_self.copyWith(
client: null == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as String,chargeCode: null == chargeCode ? _self.chargeCode : chargeCode // ignore: cast_nullable_to_non_nullable
as String,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpiringSoonRate].
extension ExpiringSoonRatePatterns on ExpiringSoonRate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpiringSoonRate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpiringSoonRate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpiringSoonRate value)  $default,){
final _that = this;
switch (_that) {
case _ExpiringSoonRate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpiringSoonRate value)?  $default,){
final _that = this;
switch (_that) {
case _ExpiringSoonRate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String client,  String chargeCode,  int daysLeft)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpiringSoonRate() when $default != null:
return $default(_that.client,_that.chargeCode,_that.daysLeft);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String client,  String chargeCode,  int daysLeft)  $default,) {final _that = this;
switch (_that) {
case _ExpiringSoonRate():
return $default(_that.client,_that.chargeCode,_that.daysLeft);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String client,  String chargeCode,  int daysLeft)?  $default,) {final _that = this;
switch (_that) {
case _ExpiringSoonRate() when $default != null:
return $default(_that.client,_that.chargeCode,_that.daysLeft);case _:
  return null;

}
}

}

/// @nodoc


class _ExpiringSoonRate implements ExpiringSoonRate {
  const _ExpiringSoonRate({required this.client, required this.chargeCode, required this.daysLeft});
  

@override final  String client;
@override final  String chargeCode;
@override final  int daysLeft;

/// Create a copy of ExpiringSoonRate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpiringSoonRateCopyWith<_ExpiringSoonRate> get copyWith => __$ExpiringSoonRateCopyWithImpl<_ExpiringSoonRate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpiringSoonRate&&(identical(other.client, client) || other.client == client)&&(identical(other.chargeCode, chargeCode) || other.chargeCode == chargeCode)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft));
}


@override
int get hashCode => Object.hash(runtimeType,client,chargeCode,daysLeft);

@override
String toString() {
  return 'ExpiringSoonRate(client: $client, chargeCode: $chargeCode, daysLeft: $daysLeft)';
}


}

/// @nodoc
abstract mixin class _$ExpiringSoonRateCopyWith<$Res> implements $ExpiringSoonRateCopyWith<$Res> {
  factory _$ExpiringSoonRateCopyWith(_ExpiringSoonRate value, $Res Function(_ExpiringSoonRate) _then) = __$ExpiringSoonRateCopyWithImpl;
@override @useResult
$Res call({
 String client, String chargeCode, int daysLeft
});




}
/// @nodoc
class __$ExpiringSoonRateCopyWithImpl<$Res>
    implements _$ExpiringSoonRateCopyWith<$Res> {
  __$ExpiringSoonRateCopyWithImpl(this._self, this._then);

  final _ExpiringSoonRate _self;
  final $Res Function(_ExpiringSoonRate) _then;

/// Create a copy of ExpiringSoonRate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? client = null,Object? chargeCode = null,Object? daysLeft = null,}) {
  return _then(_ExpiringSoonRate(
client: null == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as String,chargeCode: null == chargeCode ? _self.chargeCode : chargeCode // ignore: cast_nullable_to_non_nullable
as String,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
