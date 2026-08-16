// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recent_rate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecentRate {

 String get route; String get client; RateType get type; String get price; RateStatus get status;
/// Create a copy of RecentRate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentRateCopyWith<RecentRate> get copyWith => _$RecentRateCopyWithImpl<RecentRate>(this as RecentRate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentRate&&(identical(other.route, route) || other.route == route)&&(identical(other.client, client) || other.client == client)&&(identical(other.type, type) || other.type == type)&&(identical(other.price, price) || other.price == price)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,route,client,type,price,status);

@override
String toString() {
  return 'RecentRate(route: $route, client: $client, type: $type, price: $price, status: $status)';
}


}

/// @nodoc
abstract mixin class $RecentRateCopyWith<$Res>  {
  factory $RecentRateCopyWith(RecentRate value, $Res Function(RecentRate) _then) = _$RecentRateCopyWithImpl;
@useResult
$Res call({
 String route, String client, RateType type, String price, RateStatus status
});




}
/// @nodoc
class _$RecentRateCopyWithImpl<$Res>
    implements $RecentRateCopyWith<$Res> {
  _$RecentRateCopyWithImpl(this._self, this._then);

  final RecentRate _self;
  final $Res Function(RecentRate) _then;

/// Create a copy of RecentRate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? route = null,Object? client = null,Object? type = null,Object? price = null,Object? status = null,}) {
  return _then(_self.copyWith(
route: null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String,client: null == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RateType,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RateStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentRate].
extension RecentRatePatterns on RecentRate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentRate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentRate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentRate value)  $default,){
final _that = this;
switch (_that) {
case _RecentRate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentRate value)?  $default,){
final _that = this;
switch (_that) {
case _RecentRate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String route,  String client,  RateType type,  String price,  RateStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentRate() when $default != null:
return $default(_that.route,_that.client,_that.type,_that.price,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String route,  String client,  RateType type,  String price,  RateStatus status)  $default,) {final _that = this;
switch (_that) {
case _RecentRate():
return $default(_that.route,_that.client,_that.type,_that.price,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String route,  String client,  RateType type,  String price,  RateStatus status)?  $default,) {final _that = this;
switch (_that) {
case _RecentRate() when $default != null:
return $default(_that.route,_that.client,_that.type,_that.price,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _RecentRate implements RecentRate {
  const _RecentRate({required this.route, required this.client, required this.type, required this.price, required this.status});
  

@override final  String route;
@override final  String client;
@override final  RateType type;
@override final  String price;
@override final  RateStatus status;

/// Create a copy of RecentRate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentRateCopyWith<_RecentRate> get copyWith => __$RecentRateCopyWithImpl<_RecentRate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentRate&&(identical(other.route, route) || other.route == route)&&(identical(other.client, client) || other.client == client)&&(identical(other.type, type) || other.type == type)&&(identical(other.price, price) || other.price == price)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,route,client,type,price,status);

@override
String toString() {
  return 'RecentRate(route: $route, client: $client, type: $type, price: $price, status: $status)';
}


}

/// @nodoc
abstract mixin class _$RecentRateCopyWith<$Res> implements $RecentRateCopyWith<$Res> {
  factory _$RecentRateCopyWith(_RecentRate value, $Res Function(_RecentRate) _then) = __$RecentRateCopyWithImpl;
@override @useResult
$Res call({
 String route, String client, RateType type, String price, RateStatus status
});




}
/// @nodoc
class __$RecentRateCopyWithImpl<$Res>
    implements _$RecentRateCopyWith<$Res> {
  __$RecentRateCopyWithImpl(this._self, this._then);

  final _RecentRate _self;
  final $Res Function(_RecentRate) _then;

/// Create a copy of RecentRate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? route = null,Object? client = null,Object? type = null,Object? price = null,Object? status = null,}) {
  return _then(_RecentRate(
route: null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String,client: null == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RateType,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RateStatus,
  ));
}


}

// dart format on
