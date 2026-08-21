// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClientCompliance {

 String? get vatStatus; String? get tinNo;
/// Create a copy of ClientCompliance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientComplianceCopyWith<ClientCompliance> get copyWith => _$ClientComplianceCopyWithImpl<ClientCompliance>(this as ClientCompliance, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientCompliance&&(identical(other.vatStatus, vatStatus) || other.vatStatus == vatStatus)&&(identical(other.tinNo, tinNo) || other.tinNo == tinNo));
}


@override
int get hashCode => Object.hash(runtimeType,vatStatus,tinNo);

@override
String toString() {
  return 'ClientCompliance(vatStatus: $vatStatus, tinNo: $tinNo)';
}


}

/// @nodoc
abstract mixin class $ClientComplianceCopyWith<$Res>  {
  factory $ClientComplianceCopyWith(ClientCompliance value, $Res Function(ClientCompliance) _then) = _$ClientComplianceCopyWithImpl;
@useResult
$Res call({
 String? vatStatus, String? tinNo
});




}
/// @nodoc
class _$ClientComplianceCopyWithImpl<$Res>
    implements $ClientComplianceCopyWith<$Res> {
  _$ClientComplianceCopyWithImpl(this._self, this._then);

  final ClientCompliance _self;
  final $Res Function(ClientCompliance) _then;

/// Create a copy of ClientCompliance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vatStatus = freezed,Object? tinNo = freezed,}) {
  return _then(_self.copyWith(
vatStatus: freezed == vatStatus ? _self.vatStatus : vatStatus // ignore: cast_nullable_to_non_nullable
as String?,tinNo: freezed == tinNo ? _self.tinNo : tinNo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientCompliance].
extension ClientCompliancePatterns on ClientCompliance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientCompliance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientCompliance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientCompliance value)  $default,){
final _that = this;
switch (_that) {
case _ClientCompliance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientCompliance value)?  $default,){
final _that = this;
switch (_that) {
case _ClientCompliance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? vatStatus,  String? tinNo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientCompliance() when $default != null:
return $default(_that.vatStatus,_that.tinNo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? vatStatus,  String? tinNo)  $default,) {final _that = this;
switch (_that) {
case _ClientCompliance():
return $default(_that.vatStatus,_that.tinNo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? vatStatus,  String? tinNo)?  $default,) {final _that = this;
switch (_that) {
case _ClientCompliance() when $default != null:
return $default(_that.vatStatus,_that.tinNo);case _:
  return null;

}
}

}

/// @nodoc


class _ClientCompliance implements ClientCompliance {
  const _ClientCompliance({this.vatStatus, this.tinNo});
  

@override final  String? vatStatus;
@override final  String? tinNo;

/// Create a copy of ClientCompliance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientComplianceCopyWith<_ClientCompliance> get copyWith => __$ClientComplianceCopyWithImpl<_ClientCompliance>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientCompliance&&(identical(other.vatStatus, vatStatus) || other.vatStatus == vatStatus)&&(identical(other.tinNo, tinNo) || other.tinNo == tinNo));
}


@override
int get hashCode => Object.hash(runtimeType,vatStatus,tinNo);

@override
String toString() {
  return 'ClientCompliance(vatStatus: $vatStatus, tinNo: $tinNo)';
}


}

/// @nodoc
abstract mixin class _$ClientComplianceCopyWith<$Res> implements $ClientComplianceCopyWith<$Res> {
  factory _$ClientComplianceCopyWith(_ClientCompliance value, $Res Function(_ClientCompliance) _then) = __$ClientComplianceCopyWithImpl;
@override @useResult
$Res call({
 String? vatStatus, String? tinNo
});




}
/// @nodoc
class __$ClientComplianceCopyWithImpl<$Res>
    implements _$ClientComplianceCopyWith<$Res> {
  __$ClientComplianceCopyWithImpl(this._self, this._then);

  final _ClientCompliance _self;
  final $Res Function(_ClientCompliance) _then;

/// Create a copy of ClientCompliance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vatStatus = freezed,Object? tinNo = freezed,}) {
  return _then(_ClientCompliance(
vatStatus: freezed == vatStatus ? _self.vatStatus : vatStatus // ignore: cast_nullable_to_non_nullable
as String?,tinNo: freezed == tinNo ? _self.tinNo : tinNo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Client {

 int get id; String get accountNo; String get name; String? get tradeName; String? get email; String? get phoneNumber; String? get businessType; String? get organizationType; String? get officeAddress; String? get billingAddress; num get paymentTerms; num get thresholdLimit; num get creditLimit; ClientCompliance? get compliance; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Client
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientCopyWith<Client> get copyWith => _$ClientCopyWithImpl<Client>(this as Client, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Client&&(identical(other.id, id) || other.id == id)&&(identical(other.accountNo, accountNo) || other.accountNo == accountNo)&&(identical(other.name, name) || other.name == name)&&(identical(other.tradeName, tradeName) || other.tradeName == tradeName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.businessType, businessType) || other.businessType == businessType)&&(identical(other.organizationType, organizationType) || other.organizationType == organizationType)&&(identical(other.officeAddress, officeAddress) || other.officeAddress == officeAddress)&&(identical(other.billingAddress, billingAddress) || other.billingAddress == billingAddress)&&(identical(other.paymentTerms, paymentTerms) || other.paymentTerms == paymentTerms)&&(identical(other.thresholdLimit, thresholdLimit) || other.thresholdLimit == thresholdLimit)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.compliance, compliance) || other.compliance == compliance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,accountNo,name,tradeName,email,phoneNumber,businessType,organizationType,officeAddress,billingAddress,paymentTerms,thresholdLimit,creditLimit,compliance,createdAt,updatedAt);

@override
String toString() {
  return 'Client(id: $id, accountNo: $accountNo, name: $name, tradeName: $tradeName, email: $email, phoneNumber: $phoneNumber, businessType: $businessType, organizationType: $organizationType, officeAddress: $officeAddress, billingAddress: $billingAddress, paymentTerms: $paymentTerms, thresholdLimit: $thresholdLimit, creditLimit: $creditLimit, compliance: $compliance, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ClientCopyWith<$Res>  {
  factory $ClientCopyWith(Client value, $Res Function(Client) _then) = _$ClientCopyWithImpl;
@useResult
$Res call({
 int id, String accountNo, String name, String? tradeName, String? email, String? phoneNumber, String? businessType, String? organizationType, String? officeAddress, String? billingAddress, num paymentTerms, num thresholdLimit, num creditLimit, ClientCompliance? compliance, DateTime? createdAt, DateTime? updatedAt
});


$ClientComplianceCopyWith<$Res>? get compliance;

}
/// @nodoc
class _$ClientCopyWithImpl<$Res>
    implements $ClientCopyWith<$Res> {
  _$ClientCopyWithImpl(this._self, this._then);

  final Client _self;
  final $Res Function(Client) _then;

/// Create a copy of Client
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountNo = null,Object? name = null,Object? tradeName = freezed,Object? email = freezed,Object? phoneNumber = freezed,Object? businessType = freezed,Object? organizationType = freezed,Object? officeAddress = freezed,Object? billingAddress = freezed,Object? paymentTerms = null,Object? thresholdLimit = null,Object? creditLimit = null,Object? compliance = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,accountNo: null == accountNo ? _self.accountNo : accountNo // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tradeName: freezed == tradeName ? _self.tradeName : tradeName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,businessType: freezed == businessType ? _self.businessType : businessType // ignore: cast_nullable_to_non_nullable
as String?,organizationType: freezed == organizationType ? _self.organizationType : organizationType // ignore: cast_nullable_to_non_nullable
as String?,officeAddress: freezed == officeAddress ? _self.officeAddress : officeAddress // ignore: cast_nullable_to_non_nullable
as String?,billingAddress: freezed == billingAddress ? _self.billingAddress : billingAddress // ignore: cast_nullable_to_non_nullable
as String?,paymentTerms: null == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as num,thresholdLimit: null == thresholdLimit ? _self.thresholdLimit : thresholdLimit // ignore: cast_nullable_to_non_nullable
as num,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as num,compliance: freezed == compliance ? _self.compliance : compliance // ignore: cast_nullable_to_non_nullable
as ClientCompliance?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Client
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientComplianceCopyWith<$Res>? get compliance {
    if (_self.compliance == null) {
    return null;
  }

  return $ClientComplianceCopyWith<$Res>(_self.compliance!, (value) {
    return _then(_self.copyWith(compliance: value));
  });
}
}


/// Adds pattern-matching-related methods to [Client].
extension ClientPatterns on Client {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Client value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Client() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Client value)  $default,){
final _that = this;
switch (_that) {
case _Client():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Client value)?  $default,){
final _that = this;
switch (_that) {
case _Client() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String accountNo,  String name,  String? tradeName,  String? email,  String? phoneNumber,  String? businessType,  String? organizationType,  String? officeAddress,  String? billingAddress,  num paymentTerms,  num thresholdLimit,  num creditLimit,  ClientCompliance? compliance,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Client() when $default != null:
return $default(_that.id,_that.accountNo,_that.name,_that.tradeName,_that.email,_that.phoneNumber,_that.businessType,_that.organizationType,_that.officeAddress,_that.billingAddress,_that.paymentTerms,_that.thresholdLimit,_that.creditLimit,_that.compliance,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String accountNo,  String name,  String? tradeName,  String? email,  String? phoneNumber,  String? businessType,  String? organizationType,  String? officeAddress,  String? billingAddress,  num paymentTerms,  num thresholdLimit,  num creditLimit,  ClientCompliance? compliance,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Client():
return $default(_that.id,_that.accountNo,_that.name,_that.tradeName,_that.email,_that.phoneNumber,_that.businessType,_that.organizationType,_that.officeAddress,_that.billingAddress,_that.paymentTerms,_that.thresholdLimit,_that.creditLimit,_that.compliance,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String accountNo,  String name,  String? tradeName,  String? email,  String? phoneNumber,  String? businessType,  String? organizationType,  String? officeAddress,  String? billingAddress,  num paymentTerms,  num thresholdLimit,  num creditLimit,  ClientCompliance? compliance,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Client() when $default != null:
return $default(_that.id,_that.accountNo,_that.name,_that.tradeName,_that.email,_that.phoneNumber,_that.businessType,_that.organizationType,_that.officeAddress,_that.billingAddress,_that.paymentTerms,_that.thresholdLimit,_that.creditLimit,_that.compliance,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Client implements Client {
  const _Client({required this.id, required this.accountNo, required this.name, this.tradeName, this.email, this.phoneNumber, this.businessType, this.organizationType, this.officeAddress, this.billingAddress, this.paymentTerms = 0, this.thresholdLimit = 0, this.creditLimit = 0, this.compliance, this.createdAt, this.updatedAt});
  

@override final  int id;
@override final  String accountNo;
@override final  String name;
@override final  String? tradeName;
@override final  String? email;
@override final  String? phoneNumber;
@override final  String? businessType;
@override final  String? organizationType;
@override final  String? officeAddress;
@override final  String? billingAddress;
@override@JsonKey() final  num paymentTerms;
@override@JsonKey() final  num thresholdLimit;
@override@JsonKey() final  num creditLimit;
@override final  ClientCompliance? compliance;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Client
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientCopyWith<_Client> get copyWith => __$ClientCopyWithImpl<_Client>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Client&&(identical(other.id, id) || other.id == id)&&(identical(other.accountNo, accountNo) || other.accountNo == accountNo)&&(identical(other.name, name) || other.name == name)&&(identical(other.tradeName, tradeName) || other.tradeName == tradeName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.businessType, businessType) || other.businessType == businessType)&&(identical(other.organizationType, organizationType) || other.organizationType == organizationType)&&(identical(other.officeAddress, officeAddress) || other.officeAddress == officeAddress)&&(identical(other.billingAddress, billingAddress) || other.billingAddress == billingAddress)&&(identical(other.paymentTerms, paymentTerms) || other.paymentTerms == paymentTerms)&&(identical(other.thresholdLimit, thresholdLimit) || other.thresholdLimit == thresholdLimit)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.compliance, compliance) || other.compliance == compliance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,accountNo,name,tradeName,email,phoneNumber,businessType,organizationType,officeAddress,billingAddress,paymentTerms,thresholdLimit,creditLimit,compliance,createdAt,updatedAt);

@override
String toString() {
  return 'Client(id: $id, accountNo: $accountNo, name: $name, tradeName: $tradeName, email: $email, phoneNumber: $phoneNumber, businessType: $businessType, organizationType: $organizationType, officeAddress: $officeAddress, billingAddress: $billingAddress, paymentTerms: $paymentTerms, thresholdLimit: $thresholdLimit, creditLimit: $creditLimit, compliance: $compliance, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ClientCopyWith<$Res> implements $ClientCopyWith<$Res> {
  factory _$ClientCopyWith(_Client value, $Res Function(_Client) _then) = __$ClientCopyWithImpl;
@override @useResult
$Res call({
 int id, String accountNo, String name, String? tradeName, String? email, String? phoneNumber, String? businessType, String? organizationType, String? officeAddress, String? billingAddress, num paymentTerms, num thresholdLimit, num creditLimit, ClientCompliance? compliance, DateTime? createdAt, DateTime? updatedAt
});


@override $ClientComplianceCopyWith<$Res>? get compliance;

}
/// @nodoc
class __$ClientCopyWithImpl<$Res>
    implements _$ClientCopyWith<$Res> {
  __$ClientCopyWithImpl(this._self, this._then);

  final _Client _self;
  final $Res Function(_Client) _then;

/// Create a copy of Client
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountNo = null,Object? name = null,Object? tradeName = freezed,Object? email = freezed,Object? phoneNumber = freezed,Object? businessType = freezed,Object? organizationType = freezed,Object? officeAddress = freezed,Object? billingAddress = freezed,Object? paymentTerms = null,Object? thresholdLimit = null,Object? creditLimit = null,Object? compliance = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Client(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,accountNo: null == accountNo ? _self.accountNo : accountNo // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tradeName: freezed == tradeName ? _self.tradeName : tradeName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,businessType: freezed == businessType ? _self.businessType : businessType // ignore: cast_nullable_to_non_nullable
as String?,organizationType: freezed == organizationType ? _self.organizationType : organizationType // ignore: cast_nullable_to_non_nullable
as String?,officeAddress: freezed == officeAddress ? _self.officeAddress : officeAddress // ignore: cast_nullable_to_non_nullable
as String?,billingAddress: freezed == billingAddress ? _self.billingAddress : billingAddress // ignore: cast_nullable_to_non_nullable
as String?,paymentTerms: null == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as num,thresholdLimit: null == thresholdLimit ? _self.thresholdLimit : thresholdLimit // ignore: cast_nullable_to_non_nullable
as num,creditLimit: null == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as num,compliance: freezed == compliance ? _self.compliance : compliance // ignore: cast_nullable_to_non_nullable
as ClientCompliance?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Client
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientComplianceCopyWith<$Res>? get compliance {
    if (_self.compliance == null) {
    return null;
  }

  return $ClientComplianceCopyWith<$Res>(_self.compliance!, (value) {
    return _then(_self.copyWith(compliance: value));
  });
}
}

// dart format on
