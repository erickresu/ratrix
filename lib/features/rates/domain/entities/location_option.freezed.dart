// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocationOption {

 String? get id; String get value; String get label; String? get type; int? get islandId; int? get regionId; int? get provinceId; int? get cityId; int? get barangayId; String? get zipcode; String? get address1; String? get iata; String? get code; String? get cityName; String? get provinceName; String? get islandName;
/// Create a copy of LocationOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationOptionCopyWith<LocationOption> get copyWith => _$LocationOptionCopyWithImpl<LocationOption>(this as LocationOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationOption&&(identical(other.id, id) || other.id == id)&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label)&&(identical(other.type, type) || other.type == type)&&(identical(other.islandId, islandId) || other.islandId == islandId)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.provinceId, provinceId) || other.provinceId == provinceId)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.barangayId, barangayId) || other.barangayId == barangayId)&&(identical(other.zipcode, zipcode) || other.zipcode == zipcode)&&(identical(other.address1, address1) || other.address1 == address1)&&(identical(other.iata, iata) || other.iata == iata)&&(identical(other.code, code) || other.code == code)&&(identical(other.cityName, cityName) || other.cityName == cityName)&&(identical(other.provinceName, provinceName) || other.provinceName == provinceName)&&(identical(other.islandName, islandName) || other.islandName == islandName));
}


@override
int get hashCode => Object.hash(runtimeType,id,value,label,type,islandId,regionId,provinceId,cityId,barangayId,zipcode,address1,iata,code,cityName,provinceName,islandName);

@override
String toString() {
  return 'LocationOption(id: $id, value: $value, label: $label, type: $type, islandId: $islandId, regionId: $regionId, provinceId: $provinceId, cityId: $cityId, barangayId: $barangayId, zipcode: $zipcode, address1: $address1, iata: $iata, code: $code, cityName: $cityName, provinceName: $provinceName, islandName: $islandName)';
}


}

/// @nodoc
abstract mixin class $LocationOptionCopyWith<$Res>  {
  factory $LocationOptionCopyWith(LocationOption value, $Res Function(LocationOption) _then) = _$LocationOptionCopyWithImpl;
@useResult
$Res call({
 String? id, String value, String label, String? type, int? islandId, int? regionId, int? provinceId, int? cityId, int? barangayId, String? zipcode, String? address1, String? iata, String? code, String? cityName, String? provinceName, String? islandName
});




}
/// @nodoc
class _$LocationOptionCopyWithImpl<$Res>
    implements $LocationOptionCopyWith<$Res> {
  _$LocationOptionCopyWithImpl(this._self, this._then);

  final LocationOption _self;
  final $Res Function(LocationOption) _then;

/// Create a copy of LocationOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? value = null,Object? label = null,Object? type = freezed,Object? islandId = freezed,Object? regionId = freezed,Object? provinceId = freezed,Object? cityId = freezed,Object? barangayId = freezed,Object? zipcode = freezed,Object? address1 = freezed,Object? iata = freezed,Object? code = freezed,Object? cityName = freezed,Object? provinceName = freezed,Object? islandName = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,islandId: freezed == islandId ? _self.islandId : islandId // ignore: cast_nullable_to_non_nullable
as int?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as int?,provinceId: freezed == provinceId ? _self.provinceId : provinceId // ignore: cast_nullable_to_non_nullable
as int?,cityId: freezed == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as int?,barangayId: freezed == barangayId ? _self.barangayId : barangayId // ignore: cast_nullable_to_non_nullable
as int?,zipcode: freezed == zipcode ? _self.zipcode : zipcode // ignore: cast_nullable_to_non_nullable
as String?,address1: freezed == address1 ? _self.address1 : address1 // ignore: cast_nullable_to_non_nullable
as String?,iata: freezed == iata ? _self.iata : iata // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,cityName: freezed == cityName ? _self.cityName : cityName // ignore: cast_nullable_to_non_nullable
as String?,provinceName: freezed == provinceName ? _self.provinceName : provinceName // ignore: cast_nullable_to_non_nullable
as String?,islandName: freezed == islandName ? _self.islandName : islandName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationOption].
extension LocationOptionPatterns on LocationOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationOption value)  $default,){
final _that = this;
switch (_that) {
case _LocationOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationOption value)?  $default,){
final _that = this;
switch (_that) {
case _LocationOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String value,  String label,  String? type,  int? islandId,  int? regionId,  int? provinceId,  int? cityId,  int? barangayId,  String? zipcode,  String? address1,  String? iata,  String? code,  String? cityName,  String? provinceName,  String? islandName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationOption() when $default != null:
return $default(_that.id,_that.value,_that.label,_that.type,_that.islandId,_that.regionId,_that.provinceId,_that.cityId,_that.barangayId,_that.zipcode,_that.address1,_that.iata,_that.code,_that.cityName,_that.provinceName,_that.islandName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String value,  String label,  String? type,  int? islandId,  int? regionId,  int? provinceId,  int? cityId,  int? barangayId,  String? zipcode,  String? address1,  String? iata,  String? code,  String? cityName,  String? provinceName,  String? islandName)  $default,) {final _that = this;
switch (_that) {
case _LocationOption():
return $default(_that.id,_that.value,_that.label,_that.type,_that.islandId,_that.regionId,_that.provinceId,_that.cityId,_that.barangayId,_that.zipcode,_that.address1,_that.iata,_that.code,_that.cityName,_that.provinceName,_that.islandName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String value,  String label,  String? type,  int? islandId,  int? regionId,  int? provinceId,  int? cityId,  int? barangayId,  String? zipcode,  String? address1,  String? iata,  String? code,  String? cityName,  String? provinceName,  String? islandName)?  $default,) {final _that = this;
switch (_that) {
case _LocationOption() when $default != null:
return $default(_that.id,_that.value,_that.label,_that.type,_that.islandId,_that.regionId,_that.provinceId,_that.cityId,_that.barangayId,_that.zipcode,_that.address1,_that.iata,_that.code,_that.cityName,_that.provinceName,_that.islandName);case _:
  return null;

}
}

}

/// @nodoc


class _LocationOption extends LocationOption {
  const _LocationOption({this.id, required this.value, required this.label, this.type, this.islandId, this.regionId, this.provinceId, this.cityId, this.barangayId, this.zipcode, this.address1, this.iata, this.code, this.cityName, this.provinceName, this.islandName}): super._();
  

@override final  String? id;
@override final  String value;
@override final  String label;
@override final  String? type;
@override final  int? islandId;
@override final  int? regionId;
@override final  int? provinceId;
@override final  int? cityId;
@override final  int? barangayId;
@override final  String? zipcode;
@override final  String? address1;
@override final  String? iata;
@override final  String? code;
@override final  String? cityName;
@override final  String? provinceName;
@override final  String? islandName;

/// Create a copy of LocationOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationOptionCopyWith<_LocationOption> get copyWith => __$LocationOptionCopyWithImpl<_LocationOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationOption&&(identical(other.id, id) || other.id == id)&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label)&&(identical(other.type, type) || other.type == type)&&(identical(other.islandId, islandId) || other.islandId == islandId)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.provinceId, provinceId) || other.provinceId == provinceId)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.barangayId, barangayId) || other.barangayId == barangayId)&&(identical(other.zipcode, zipcode) || other.zipcode == zipcode)&&(identical(other.address1, address1) || other.address1 == address1)&&(identical(other.iata, iata) || other.iata == iata)&&(identical(other.code, code) || other.code == code)&&(identical(other.cityName, cityName) || other.cityName == cityName)&&(identical(other.provinceName, provinceName) || other.provinceName == provinceName)&&(identical(other.islandName, islandName) || other.islandName == islandName));
}


@override
int get hashCode => Object.hash(runtimeType,id,value,label,type,islandId,regionId,provinceId,cityId,barangayId,zipcode,address1,iata,code,cityName,provinceName,islandName);

@override
String toString() {
  return 'LocationOption(id: $id, value: $value, label: $label, type: $type, islandId: $islandId, regionId: $regionId, provinceId: $provinceId, cityId: $cityId, barangayId: $barangayId, zipcode: $zipcode, address1: $address1, iata: $iata, code: $code, cityName: $cityName, provinceName: $provinceName, islandName: $islandName)';
}


}

/// @nodoc
abstract mixin class _$LocationOptionCopyWith<$Res> implements $LocationOptionCopyWith<$Res> {
  factory _$LocationOptionCopyWith(_LocationOption value, $Res Function(_LocationOption) _then) = __$LocationOptionCopyWithImpl;
@override @useResult
$Res call({
 String? id, String value, String label, String? type, int? islandId, int? regionId, int? provinceId, int? cityId, int? barangayId, String? zipcode, String? address1, String? iata, String? code, String? cityName, String? provinceName, String? islandName
});




}
/// @nodoc
class __$LocationOptionCopyWithImpl<$Res>
    implements _$LocationOptionCopyWith<$Res> {
  __$LocationOptionCopyWithImpl(this._self, this._then);

  final _LocationOption _self;
  final $Res Function(_LocationOption) _then;

/// Create a copy of LocationOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? value = null,Object? label = null,Object? type = freezed,Object? islandId = freezed,Object? regionId = freezed,Object? provinceId = freezed,Object? cityId = freezed,Object? barangayId = freezed,Object? zipcode = freezed,Object? address1 = freezed,Object? iata = freezed,Object? code = freezed,Object? cityName = freezed,Object? provinceName = freezed,Object? islandName = freezed,}) {
  return _then(_LocationOption(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,islandId: freezed == islandId ? _self.islandId : islandId // ignore: cast_nullable_to_non_nullable
as int?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as int?,provinceId: freezed == provinceId ? _self.provinceId : provinceId // ignore: cast_nullable_to_non_nullable
as int?,cityId: freezed == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as int?,barangayId: freezed == barangayId ? _self.barangayId : barangayId // ignore: cast_nullable_to_non_nullable
as int?,zipcode: freezed == zipcode ? _self.zipcode : zipcode // ignore: cast_nullable_to_non_nullable
as String?,address1: freezed == address1 ? _self.address1 : address1 // ignore: cast_nullable_to_non_nullable
as String?,iata: freezed == iata ? _self.iata : iata // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,cityName: freezed == cityName ? _self.cityName : cityName // ignore: cast_nullable_to_non_nullable
as String?,provinceName: freezed == provinceName ? _self.provinceName : provinceName // ignore: cast_nullable_to_non_nullable
as String?,islandName: freezed == islandName ? _self.islandName : islandName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
