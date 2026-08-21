// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'published_rate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PublishedRate {

 String get id; String get chargeCode; FreightMode get freightMode; ServiceMode get serviceMode; String get routeLabel; int get routeCount; RateStatus get status; String get expiryLabel; DateTime? get expiryDate;
/// Create a copy of PublishedRate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublishedRateCopyWith<PublishedRate> get copyWith => _$PublishedRateCopyWithImpl<PublishedRate>(this as PublishedRate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublishedRate&&(identical(other.id, id) || other.id == id)&&(identical(other.chargeCode, chargeCode) || other.chargeCode == chargeCode)&&(identical(other.freightMode, freightMode) || other.freightMode == freightMode)&&(identical(other.serviceMode, serviceMode) || other.serviceMode == serviceMode)&&(identical(other.routeLabel, routeLabel) || other.routeLabel == routeLabel)&&(identical(other.routeCount, routeCount) || other.routeCount == routeCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiryLabel, expiryLabel) || other.expiryLabel == expiryLabel)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,chargeCode,freightMode,serviceMode,routeLabel,routeCount,status,expiryLabel,expiryDate);

@override
String toString() {
  return 'PublishedRate(id: $id, chargeCode: $chargeCode, freightMode: $freightMode, serviceMode: $serviceMode, routeLabel: $routeLabel, routeCount: $routeCount, status: $status, expiryLabel: $expiryLabel, expiryDate: $expiryDate)';
}


}

/// @nodoc
abstract mixin class $PublishedRateCopyWith<$Res>  {
  factory $PublishedRateCopyWith(PublishedRate value, $Res Function(PublishedRate) _then) = _$PublishedRateCopyWithImpl;
@useResult
$Res call({
 String id, String chargeCode, FreightMode freightMode, ServiceMode serviceMode, String routeLabel, int routeCount, RateStatus status, String expiryLabel, DateTime? expiryDate
});




}
/// @nodoc
class _$PublishedRateCopyWithImpl<$Res>
    implements $PublishedRateCopyWith<$Res> {
  _$PublishedRateCopyWithImpl(this._self, this._then);

  final PublishedRate _self;
  final $Res Function(PublishedRate) _then;

/// Create a copy of PublishedRate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chargeCode = null,Object? freightMode = null,Object? serviceMode = null,Object? routeLabel = null,Object? routeCount = null,Object? status = null,Object? expiryLabel = null,Object? expiryDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chargeCode: null == chargeCode ? _self.chargeCode : chargeCode // ignore: cast_nullable_to_non_nullable
as String,freightMode: null == freightMode ? _self.freightMode : freightMode // ignore: cast_nullable_to_non_nullable
as FreightMode,serviceMode: null == serviceMode ? _self.serviceMode : serviceMode // ignore: cast_nullable_to_non_nullable
as ServiceMode,routeLabel: null == routeLabel ? _self.routeLabel : routeLabel // ignore: cast_nullable_to_non_nullable
as String,routeCount: null == routeCount ? _self.routeCount : routeCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RateStatus,expiryLabel: null == expiryLabel ? _self.expiryLabel : expiryLabel // ignore: cast_nullable_to_non_nullable
as String,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PublishedRate].
extension PublishedRatePatterns on PublishedRate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublishedRate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublishedRate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublishedRate value)  $default,){
final _that = this;
switch (_that) {
case _PublishedRate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublishedRate value)?  $default,){
final _that = this;
switch (_that) {
case _PublishedRate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String chargeCode,  FreightMode freightMode,  ServiceMode serviceMode,  String routeLabel,  int routeCount,  RateStatus status,  String expiryLabel,  DateTime? expiryDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublishedRate() when $default != null:
return $default(_that.id,_that.chargeCode,_that.freightMode,_that.serviceMode,_that.routeLabel,_that.routeCount,_that.status,_that.expiryLabel,_that.expiryDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String chargeCode,  FreightMode freightMode,  ServiceMode serviceMode,  String routeLabel,  int routeCount,  RateStatus status,  String expiryLabel,  DateTime? expiryDate)  $default,) {final _that = this;
switch (_that) {
case _PublishedRate():
return $default(_that.id,_that.chargeCode,_that.freightMode,_that.serviceMode,_that.routeLabel,_that.routeCount,_that.status,_that.expiryLabel,_that.expiryDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String chargeCode,  FreightMode freightMode,  ServiceMode serviceMode,  String routeLabel,  int routeCount,  RateStatus status,  String expiryLabel,  DateTime? expiryDate)?  $default,) {final _that = this;
switch (_that) {
case _PublishedRate() when $default != null:
return $default(_that.id,_that.chargeCode,_that.freightMode,_that.serviceMode,_that.routeLabel,_that.routeCount,_that.status,_that.expiryLabel,_that.expiryDate);case _:
  return null;

}
}

}

/// @nodoc


class _PublishedRate implements PublishedRate {
  const _PublishedRate({required this.id, required this.chargeCode, required this.freightMode, required this.serviceMode, required this.routeLabel, required this.routeCount, required this.status, required this.expiryLabel, this.expiryDate});
  

@override final  String id;
@override final  String chargeCode;
@override final  FreightMode freightMode;
@override final  ServiceMode serviceMode;
@override final  String routeLabel;
@override final  int routeCount;
@override final  RateStatus status;
@override final  String expiryLabel;
@override final  DateTime? expiryDate;

/// Create a copy of PublishedRate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublishedRateCopyWith<_PublishedRate> get copyWith => __$PublishedRateCopyWithImpl<_PublishedRate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublishedRate&&(identical(other.id, id) || other.id == id)&&(identical(other.chargeCode, chargeCode) || other.chargeCode == chargeCode)&&(identical(other.freightMode, freightMode) || other.freightMode == freightMode)&&(identical(other.serviceMode, serviceMode) || other.serviceMode == serviceMode)&&(identical(other.routeLabel, routeLabel) || other.routeLabel == routeLabel)&&(identical(other.routeCount, routeCount) || other.routeCount == routeCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiryLabel, expiryLabel) || other.expiryLabel == expiryLabel)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,chargeCode,freightMode,serviceMode,routeLabel,routeCount,status,expiryLabel,expiryDate);

@override
String toString() {
  return 'PublishedRate(id: $id, chargeCode: $chargeCode, freightMode: $freightMode, serviceMode: $serviceMode, routeLabel: $routeLabel, routeCount: $routeCount, status: $status, expiryLabel: $expiryLabel, expiryDate: $expiryDate)';
}


}

/// @nodoc
abstract mixin class _$PublishedRateCopyWith<$Res> implements $PublishedRateCopyWith<$Res> {
  factory _$PublishedRateCopyWith(_PublishedRate value, $Res Function(_PublishedRate) _then) = __$PublishedRateCopyWithImpl;
@override @useResult
$Res call({
 String id, String chargeCode, FreightMode freightMode, ServiceMode serviceMode, String routeLabel, int routeCount, RateStatus status, String expiryLabel, DateTime? expiryDate
});




}
/// @nodoc
class __$PublishedRateCopyWithImpl<$Res>
    implements _$PublishedRateCopyWith<$Res> {
  __$PublishedRateCopyWithImpl(this._self, this._then);

  final _PublishedRate _self;
  final $Res Function(_PublishedRate) _then;

/// Create a copy of PublishedRate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chargeCode = null,Object? freightMode = null,Object? serviceMode = null,Object? routeLabel = null,Object? routeCount = null,Object? status = null,Object? expiryLabel = null,Object? expiryDate = freezed,}) {
  return _then(_PublishedRate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chargeCode: null == chargeCode ? _self.chargeCode : chargeCode // ignore: cast_nullable_to_non_nullable
as String,freightMode: null == freightMode ? _self.freightMode : freightMode // ignore: cast_nullable_to_non_nullable
as FreightMode,serviceMode: null == serviceMode ? _self.serviceMode : serviceMode // ignore: cast_nullable_to_non_nullable
as ServiceMode,routeLabel: null == routeLabel ? _self.routeLabel : routeLabel // ignore: cast_nullable_to_non_nullable
as String,routeCount: null == routeCount ? _self.routeCount : routeCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RateStatus,expiryLabel: null == expiryLabel ? _self.expiryLabel : expiryLabel // ignore: cast_nullable_to_non_nullable
as String,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
