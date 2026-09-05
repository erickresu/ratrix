// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_rate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClientRate {

 String get id; String get clientId; String get chargeCode; FreightMode get freightMode; ServiceMode get serviceMode; int get routeCount; RateStatus get status; String get expiryLabel; DateTime? get expiryDate; DateTime? get createdAt;
/// Create a copy of ClientRate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientRateCopyWith<ClientRate> get copyWith => _$ClientRateCopyWithImpl<ClientRate>(this as ClientRate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientRate&&(identical(other.id, id) || other.id == id)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.chargeCode, chargeCode) || other.chargeCode == chargeCode)&&(identical(other.freightMode, freightMode) || other.freightMode == freightMode)&&(identical(other.serviceMode, serviceMode) || other.serviceMode == serviceMode)&&(identical(other.routeCount, routeCount) || other.routeCount == routeCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiryLabel, expiryLabel) || other.expiryLabel == expiryLabel)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,clientId,chargeCode,freightMode,serviceMode,routeCount,status,expiryLabel,expiryDate,createdAt);

@override
String toString() {
  return 'ClientRate(id: $id, clientId: $clientId, chargeCode: $chargeCode, freightMode: $freightMode, serviceMode: $serviceMode, routeCount: $routeCount, status: $status, expiryLabel: $expiryLabel, expiryDate: $expiryDate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ClientRateCopyWith<$Res>  {
  factory $ClientRateCopyWith(ClientRate value, $Res Function(ClientRate) _then) = _$ClientRateCopyWithImpl;
@useResult
$Res call({
 String id, String clientId, String chargeCode, FreightMode freightMode, ServiceMode serviceMode, int routeCount, RateStatus status, String expiryLabel, DateTime? expiryDate, DateTime? createdAt
});




}
/// @nodoc
class _$ClientRateCopyWithImpl<$Res>
    implements $ClientRateCopyWith<$Res> {
  _$ClientRateCopyWithImpl(this._self, this._then);

  final ClientRate _self;
  final $Res Function(ClientRate) _then;

/// Create a copy of ClientRate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? clientId = null,Object? chargeCode = null,Object? freightMode = null,Object? serviceMode = null,Object? routeCount = null,Object? status = null,Object? expiryLabel = null,Object? expiryDate = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,chargeCode: null == chargeCode ? _self.chargeCode : chargeCode // ignore: cast_nullable_to_non_nullable
as String,freightMode: null == freightMode ? _self.freightMode : freightMode // ignore: cast_nullable_to_non_nullable
as FreightMode,serviceMode: null == serviceMode ? _self.serviceMode : serviceMode // ignore: cast_nullable_to_non_nullable
as ServiceMode,routeCount: null == routeCount ? _self.routeCount : routeCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RateStatus,expiryLabel: null == expiryLabel ? _self.expiryLabel : expiryLabel // ignore: cast_nullable_to_non_nullable
as String,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientRate].
extension ClientRatePatterns on ClientRate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientRate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientRate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientRate value)  $default,){
final _that = this;
switch (_that) {
case _ClientRate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientRate value)?  $default,){
final _that = this;
switch (_that) {
case _ClientRate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String clientId,  String chargeCode,  FreightMode freightMode,  ServiceMode serviceMode,  int routeCount,  RateStatus status,  String expiryLabel,  DateTime? expiryDate,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientRate() when $default != null:
return $default(_that.id,_that.clientId,_that.chargeCode,_that.freightMode,_that.serviceMode,_that.routeCount,_that.status,_that.expiryLabel,_that.expiryDate,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String clientId,  String chargeCode,  FreightMode freightMode,  ServiceMode serviceMode,  int routeCount,  RateStatus status,  String expiryLabel,  DateTime? expiryDate,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ClientRate():
return $default(_that.id,_that.clientId,_that.chargeCode,_that.freightMode,_that.serviceMode,_that.routeCount,_that.status,_that.expiryLabel,_that.expiryDate,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String clientId,  String chargeCode,  FreightMode freightMode,  ServiceMode serviceMode,  int routeCount,  RateStatus status,  String expiryLabel,  DateTime? expiryDate,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ClientRate() when $default != null:
return $default(_that.id,_that.clientId,_that.chargeCode,_that.freightMode,_that.serviceMode,_that.routeCount,_that.status,_that.expiryLabel,_that.expiryDate,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _ClientRate implements ClientRate {
  const _ClientRate({required this.id, required this.clientId, required this.chargeCode, required this.freightMode, required this.serviceMode, required this.routeCount, required this.status, required this.expiryLabel, this.expiryDate, this.createdAt});
  

@override final  String id;
@override final  String clientId;
@override final  String chargeCode;
@override final  FreightMode freightMode;
@override final  ServiceMode serviceMode;
@override final  int routeCount;
@override final  RateStatus status;
@override final  String expiryLabel;
@override final  DateTime? expiryDate;
@override final  DateTime? createdAt;

/// Create a copy of ClientRate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientRateCopyWith<_ClientRate> get copyWith => __$ClientRateCopyWithImpl<_ClientRate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientRate&&(identical(other.id, id) || other.id == id)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.chargeCode, chargeCode) || other.chargeCode == chargeCode)&&(identical(other.freightMode, freightMode) || other.freightMode == freightMode)&&(identical(other.serviceMode, serviceMode) || other.serviceMode == serviceMode)&&(identical(other.routeCount, routeCount) || other.routeCount == routeCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiryLabel, expiryLabel) || other.expiryLabel == expiryLabel)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,clientId,chargeCode,freightMode,serviceMode,routeCount,status,expiryLabel,expiryDate,createdAt);

@override
String toString() {
  return 'ClientRate(id: $id, clientId: $clientId, chargeCode: $chargeCode, freightMode: $freightMode, serviceMode: $serviceMode, routeCount: $routeCount, status: $status, expiryLabel: $expiryLabel, expiryDate: $expiryDate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ClientRateCopyWith<$Res> implements $ClientRateCopyWith<$Res> {
  factory _$ClientRateCopyWith(_ClientRate value, $Res Function(_ClientRate) _then) = __$ClientRateCopyWithImpl;
@override @useResult
$Res call({
 String id, String clientId, String chargeCode, FreightMode freightMode, ServiceMode serviceMode, int routeCount, RateStatus status, String expiryLabel, DateTime? expiryDate, DateTime? createdAt
});




}
/// @nodoc
class __$ClientRateCopyWithImpl<$Res>
    implements _$ClientRateCopyWith<$Res> {
  __$ClientRateCopyWithImpl(this._self, this._then);

  final _ClientRate _self;
  final $Res Function(_ClientRate) _then;

/// Create a copy of ClientRate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? clientId = null,Object? chargeCode = null,Object? freightMode = null,Object? serviceMode = null,Object? routeCount = null,Object? status = null,Object? expiryLabel = null,Object? expiryDate = freezed,Object? createdAt = freezed,}) {
  return _then(_ClientRate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,chargeCode: null == chargeCode ? _self.chargeCode : chargeCode // ignore: cast_nullable_to_non_nullable
as String,freightMode: null == freightMode ? _self.freightMode : freightMode // ignore: cast_nullable_to_non_nullable
as FreightMode,serviceMode: null == serviceMode ? _self.serviceMode : serviceMode // ignore: cast_nullable_to_non_nullable
as ServiceMode,routeCount: null == routeCount ? _self.routeCount : routeCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RateStatus,expiryLabel: null == expiryLabel ? _self.expiryLabel : expiryLabel // ignore: cast_nullable_to_non_nullable
as String,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
