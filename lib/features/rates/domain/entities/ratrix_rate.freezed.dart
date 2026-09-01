// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ratrix_rate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RatrixLookupOption {

 int get id; String get name; String? get code;
/// Create a copy of RatrixLookupOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RatrixLookupOptionCopyWith<RatrixLookupOption> get copyWith => _$RatrixLookupOptionCopyWithImpl<RatrixLookupOption>(this as RatrixLookupOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RatrixLookupOption&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,code);

@override
String toString() {
  return 'RatrixLookupOption(id: $id, name: $name, code: $code)';
}


}

/// @nodoc
abstract mixin class $RatrixLookupOptionCopyWith<$Res>  {
  factory $RatrixLookupOptionCopyWith(RatrixLookupOption value, $Res Function(RatrixLookupOption) _then) = _$RatrixLookupOptionCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? code
});




}
/// @nodoc
class _$RatrixLookupOptionCopyWithImpl<$Res>
    implements $RatrixLookupOptionCopyWith<$Res> {
  _$RatrixLookupOptionCopyWithImpl(this._self, this._then);

  final RatrixLookupOption _self;
  final $Res Function(RatrixLookupOption) _then;

/// Create a copy of RatrixLookupOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? code = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RatrixLookupOption].
extension RatrixLookupOptionPatterns on RatrixLookupOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RatrixLookupOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RatrixLookupOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RatrixLookupOption value)  $default,){
final _that = this;
switch (_that) {
case _RatrixLookupOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RatrixLookupOption value)?  $default,){
final _that = this;
switch (_that) {
case _RatrixLookupOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RatrixLookupOption() when $default != null:
return $default(_that.id,_that.name,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? code)  $default,) {final _that = this;
switch (_that) {
case _RatrixLookupOption():
return $default(_that.id,_that.name,_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? code)?  $default,) {final _that = this;
switch (_that) {
case _RatrixLookupOption() when $default != null:
return $default(_that.id,_that.name,_that.code);case _:
  return null;

}
}

}

/// @nodoc


class _RatrixLookupOption implements RatrixLookupOption {
  const _RatrixLookupOption({required this.id, required this.name, this.code});
  

@override final  int id;
@override final  String name;
@override final  String? code;

/// Create a copy of RatrixLookupOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RatrixLookupOptionCopyWith<_RatrixLookupOption> get copyWith => __$RatrixLookupOptionCopyWithImpl<_RatrixLookupOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RatrixLookupOption&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,code);

@override
String toString() {
  return 'RatrixLookupOption(id: $id, name: $name, code: $code)';
}


}

/// @nodoc
abstract mixin class _$RatrixLookupOptionCopyWith<$Res> implements $RatrixLookupOptionCopyWith<$Res> {
  factory _$RatrixLookupOptionCopyWith(_RatrixLookupOption value, $Res Function(_RatrixLookupOption) _then) = __$RatrixLookupOptionCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? code
});




}
/// @nodoc
class __$RatrixLookupOptionCopyWithImpl<$Res>
    implements _$RatrixLookupOptionCopyWith<$Res> {
  __$RatrixLookupOptionCopyWithImpl(this._self, this._then);

  final _RatrixLookupOption _self;
  final $Res Function(_RatrixLookupOption) _then;

/// Create a copy of RatrixLookupOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? code = freezed,}) {
  return _then(_RatrixLookupOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$RatrixAddress {

 int? get id; int? get cityId; int? get provinceId; int? get regionId; int? get islandId; int? get barangayId; String? get zipcode; String? get label; String? get address1;
/// Create a copy of RatrixAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RatrixAddressCopyWith<RatrixAddress> get copyWith => _$RatrixAddressCopyWithImpl<RatrixAddress>(this as RatrixAddress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RatrixAddress&&(identical(other.id, id) || other.id == id)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.provinceId, provinceId) || other.provinceId == provinceId)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.islandId, islandId) || other.islandId == islandId)&&(identical(other.barangayId, barangayId) || other.barangayId == barangayId)&&(identical(other.zipcode, zipcode) || other.zipcode == zipcode)&&(identical(other.label, label) || other.label == label)&&(identical(other.address1, address1) || other.address1 == address1));
}


@override
int get hashCode => Object.hash(runtimeType,id,cityId,provinceId,regionId,islandId,barangayId,zipcode,label,address1);

@override
String toString() {
  return 'RatrixAddress(id: $id, cityId: $cityId, provinceId: $provinceId, regionId: $regionId, islandId: $islandId, barangayId: $barangayId, zipcode: $zipcode, label: $label, address1: $address1)';
}


}

/// @nodoc
abstract mixin class $RatrixAddressCopyWith<$Res>  {
  factory $RatrixAddressCopyWith(RatrixAddress value, $Res Function(RatrixAddress) _then) = _$RatrixAddressCopyWithImpl;
@useResult
$Res call({
 int? id, int? cityId, int? provinceId, int? regionId, int? islandId, int? barangayId, String? zipcode, String? label, String? address1
});




}
/// @nodoc
class _$RatrixAddressCopyWithImpl<$Res>
    implements $RatrixAddressCopyWith<$Res> {
  _$RatrixAddressCopyWithImpl(this._self, this._then);

  final RatrixAddress _self;
  final $Res Function(RatrixAddress) _then;

/// Create a copy of RatrixAddress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? cityId = freezed,Object? provinceId = freezed,Object? regionId = freezed,Object? islandId = freezed,Object? barangayId = freezed,Object? zipcode = freezed,Object? label = freezed,Object? address1 = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,cityId: freezed == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as int?,provinceId: freezed == provinceId ? _self.provinceId : provinceId // ignore: cast_nullable_to_non_nullable
as int?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as int?,islandId: freezed == islandId ? _self.islandId : islandId // ignore: cast_nullable_to_non_nullable
as int?,barangayId: freezed == barangayId ? _self.barangayId : barangayId // ignore: cast_nullable_to_non_nullable
as int?,zipcode: freezed == zipcode ? _self.zipcode : zipcode // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,address1: freezed == address1 ? _self.address1 : address1 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RatrixAddress].
extension RatrixAddressPatterns on RatrixAddress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RatrixAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RatrixAddress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RatrixAddress value)  $default,){
final _that = this;
switch (_that) {
case _RatrixAddress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RatrixAddress value)?  $default,){
final _that = this;
switch (_that) {
case _RatrixAddress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? cityId,  int? provinceId,  int? regionId,  int? islandId,  int? barangayId,  String? zipcode,  String? label,  String? address1)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RatrixAddress() when $default != null:
return $default(_that.id,_that.cityId,_that.provinceId,_that.regionId,_that.islandId,_that.barangayId,_that.zipcode,_that.label,_that.address1);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? cityId,  int? provinceId,  int? regionId,  int? islandId,  int? barangayId,  String? zipcode,  String? label,  String? address1)  $default,) {final _that = this;
switch (_that) {
case _RatrixAddress():
return $default(_that.id,_that.cityId,_that.provinceId,_that.regionId,_that.islandId,_that.barangayId,_that.zipcode,_that.label,_that.address1);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? cityId,  int? provinceId,  int? regionId,  int? islandId,  int? barangayId,  String? zipcode,  String? label,  String? address1)?  $default,) {final _that = this;
switch (_that) {
case _RatrixAddress() when $default != null:
return $default(_that.id,_that.cityId,_that.provinceId,_that.regionId,_that.islandId,_that.barangayId,_that.zipcode,_that.label,_that.address1);case _:
  return null;

}
}

}

/// @nodoc


class _RatrixAddress extends RatrixAddress {
  const _RatrixAddress({this.id, this.cityId, this.provinceId, this.regionId, this.islandId, this.barangayId, this.zipcode, this.label, this.address1}): super._();
  

@override final  int? id;
@override final  int? cityId;
@override final  int? provinceId;
@override final  int? regionId;
@override final  int? islandId;
@override final  int? barangayId;
@override final  String? zipcode;
@override final  String? label;
@override final  String? address1;

/// Create a copy of RatrixAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RatrixAddressCopyWith<_RatrixAddress> get copyWith => __$RatrixAddressCopyWithImpl<_RatrixAddress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RatrixAddress&&(identical(other.id, id) || other.id == id)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.provinceId, provinceId) || other.provinceId == provinceId)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.islandId, islandId) || other.islandId == islandId)&&(identical(other.barangayId, barangayId) || other.barangayId == barangayId)&&(identical(other.zipcode, zipcode) || other.zipcode == zipcode)&&(identical(other.label, label) || other.label == label)&&(identical(other.address1, address1) || other.address1 == address1));
}


@override
int get hashCode => Object.hash(runtimeType,id,cityId,provinceId,regionId,islandId,barangayId,zipcode,label,address1);

@override
String toString() {
  return 'RatrixAddress(id: $id, cityId: $cityId, provinceId: $provinceId, regionId: $regionId, islandId: $islandId, barangayId: $barangayId, zipcode: $zipcode, label: $label, address1: $address1)';
}


}

/// @nodoc
abstract mixin class _$RatrixAddressCopyWith<$Res> implements $RatrixAddressCopyWith<$Res> {
  factory _$RatrixAddressCopyWith(_RatrixAddress value, $Res Function(_RatrixAddress) _then) = __$RatrixAddressCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? cityId, int? provinceId, int? regionId, int? islandId, int? barangayId, String? zipcode, String? label, String? address1
});




}
/// @nodoc
class __$RatrixAddressCopyWithImpl<$Res>
    implements _$RatrixAddressCopyWith<$Res> {
  __$RatrixAddressCopyWithImpl(this._self, this._then);

  final _RatrixAddress _self;
  final $Res Function(_RatrixAddress) _then;

/// Create a copy of RatrixAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? cityId = freezed,Object? provinceId = freezed,Object? regionId = freezed,Object? islandId = freezed,Object? barangayId = freezed,Object? zipcode = freezed,Object? label = freezed,Object? address1 = freezed,}) {
  return _then(_RatrixAddress(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,cityId: freezed == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as int?,provinceId: freezed == provinceId ? _self.provinceId : provinceId // ignore: cast_nullable_to_non_nullable
as int?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as int?,islandId: freezed == islandId ? _self.islandId : islandId // ignore: cast_nullable_to_non_nullable
as int?,barangayId: freezed == barangayId ? _self.barangayId : barangayId // ignore: cast_nullable_to_non_nullable
as int?,zipcode: freezed == zipcode ? _self.zipcode : zipcode // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,address1: freezed == address1 ? _self.address1 : address1 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$RatrixBreakweight {

 num get min; num get max; num get rate; num? get expressRate;
/// Create a copy of RatrixBreakweight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RatrixBreakweightCopyWith<RatrixBreakweight> get copyWith => _$RatrixBreakweightCopyWithImpl<RatrixBreakweight>(this as RatrixBreakweight, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RatrixBreakweight&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.expressRate, expressRate) || other.expressRate == expressRate));
}


@override
int get hashCode => Object.hash(runtimeType,min,max,rate,expressRate);

@override
String toString() {
  return 'RatrixBreakweight(min: $min, max: $max, rate: $rate, expressRate: $expressRate)';
}


}

/// @nodoc
abstract mixin class $RatrixBreakweightCopyWith<$Res>  {
  factory $RatrixBreakweightCopyWith(RatrixBreakweight value, $Res Function(RatrixBreakweight) _then) = _$RatrixBreakweightCopyWithImpl;
@useResult
$Res call({
 num min, num max, num rate, num? expressRate
});




}
/// @nodoc
class _$RatrixBreakweightCopyWithImpl<$Res>
    implements $RatrixBreakweightCopyWith<$Res> {
  _$RatrixBreakweightCopyWithImpl(this._self, this._then);

  final RatrixBreakweight _self;
  final $Res Function(RatrixBreakweight) _then;

/// Create a copy of RatrixBreakweight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? min = null,Object? max = null,Object? rate = null,Object? expressRate = freezed,}) {
  return _then(_self.copyWith(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as num,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as num,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as num,expressRate: freezed == expressRate ? _self.expressRate : expressRate // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}

}


/// Adds pattern-matching-related methods to [RatrixBreakweight].
extension RatrixBreakweightPatterns on RatrixBreakweight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RatrixBreakweight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RatrixBreakweight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RatrixBreakweight value)  $default,){
final _that = this;
switch (_that) {
case _RatrixBreakweight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RatrixBreakweight value)?  $default,){
final _that = this;
switch (_that) {
case _RatrixBreakweight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num min,  num max,  num rate,  num? expressRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RatrixBreakweight() when $default != null:
return $default(_that.min,_that.max,_that.rate,_that.expressRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num min,  num max,  num rate,  num? expressRate)  $default,) {final _that = this;
switch (_that) {
case _RatrixBreakweight():
return $default(_that.min,_that.max,_that.rate,_that.expressRate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num min,  num max,  num rate,  num? expressRate)?  $default,) {final _that = this;
switch (_that) {
case _RatrixBreakweight() when $default != null:
return $default(_that.min,_that.max,_that.rate,_that.expressRate);case _:
  return null;

}
}

}

/// @nodoc


class _RatrixBreakweight extends RatrixBreakweight {
  const _RatrixBreakweight({required this.min, required this.max, required this.rate, this.expressRate}): super._();
  

@override final  num min;
@override final  num max;
@override final  num rate;
@override final  num? expressRate;

/// Create a copy of RatrixBreakweight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RatrixBreakweightCopyWith<_RatrixBreakweight> get copyWith => __$RatrixBreakweightCopyWithImpl<_RatrixBreakweight>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RatrixBreakweight&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.expressRate, expressRate) || other.expressRate == expressRate));
}


@override
int get hashCode => Object.hash(runtimeType,min,max,rate,expressRate);

@override
String toString() {
  return 'RatrixBreakweight(min: $min, max: $max, rate: $rate, expressRate: $expressRate)';
}


}

/// @nodoc
abstract mixin class _$RatrixBreakweightCopyWith<$Res> implements $RatrixBreakweightCopyWith<$Res> {
  factory _$RatrixBreakweightCopyWith(_RatrixBreakweight value, $Res Function(_RatrixBreakweight) _then) = __$RatrixBreakweightCopyWithImpl;
@override @useResult
$Res call({
 num min, num max, num rate, num? expressRate
});




}
/// @nodoc
class __$RatrixBreakweightCopyWithImpl<$Res>
    implements _$RatrixBreakweightCopyWith<$Res> {
  __$RatrixBreakweightCopyWithImpl(this._self, this._then);

  final _RatrixBreakweight _self;
  final $Res Function(_RatrixBreakweight) _then;

/// Create a copy of RatrixBreakweight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? min = null,Object? max = null,Object? rate = null,Object? expressRate = freezed,}) {
  return _then(_RatrixBreakweight(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as num,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as num,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as num,expressRate: freezed == expressRate ? _self.expressRate : expressRate // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}


}

/// @nodoc
mixin _$RatrixRoute {

 String? get id; int? get vehicleTypeId; int? get containerSizeId; int? get frequencyBasisId; num? get minDistance; num? get maxDistance; int? get numberOfTrips; num? get excessRate; num? get timeInHours; num? get rate; List<RatrixBreakweight> get breakweights; RatrixAddress? get origin; RatrixAddress? get destination;
/// Create a copy of RatrixRoute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RatrixRouteCopyWith<RatrixRoute> get copyWith => _$RatrixRouteCopyWithImpl<RatrixRoute>(this as RatrixRoute, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RatrixRoute&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleTypeId, vehicleTypeId) || other.vehicleTypeId == vehicleTypeId)&&(identical(other.containerSizeId, containerSizeId) || other.containerSizeId == containerSizeId)&&(identical(other.frequencyBasisId, frequencyBasisId) || other.frequencyBasisId == frequencyBasisId)&&(identical(other.minDistance, minDistance) || other.minDistance == minDistance)&&(identical(other.maxDistance, maxDistance) || other.maxDistance == maxDistance)&&(identical(other.numberOfTrips, numberOfTrips) || other.numberOfTrips == numberOfTrips)&&(identical(other.excessRate, excessRate) || other.excessRate == excessRate)&&(identical(other.timeInHours, timeInHours) || other.timeInHours == timeInHours)&&(identical(other.rate, rate) || other.rate == rate)&&const DeepCollectionEquality().equals(other.breakweights, breakweights)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination));
}


@override
int get hashCode => Object.hash(runtimeType,id,vehicleTypeId,containerSizeId,frequencyBasisId,minDistance,maxDistance,numberOfTrips,excessRate,timeInHours,rate,const DeepCollectionEquality().hash(breakweights),origin,destination);

@override
String toString() {
  return 'RatrixRoute(id: $id, vehicleTypeId: $vehicleTypeId, containerSizeId: $containerSizeId, frequencyBasisId: $frequencyBasisId, minDistance: $minDistance, maxDistance: $maxDistance, numberOfTrips: $numberOfTrips, excessRate: $excessRate, timeInHours: $timeInHours, rate: $rate, breakweights: $breakweights, origin: $origin, destination: $destination)';
}


}

/// @nodoc
abstract mixin class $RatrixRouteCopyWith<$Res>  {
  factory $RatrixRouteCopyWith(RatrixRoute value, $Res Function(RatrixRoute) _then) = _$RatrixRouteCopyWithImpl;
@useResult
$Res call({
 String? id, int? vehicleTypeId, int? containerSizeId, int? frequencyBasisId, num? minDistance, num? maxDistance, int? numberOfTrips, num? excessRate, num? timeInHours, num? rate, List<RatrixBreakweight> breakweights, RatrixAddress? origin, RatrixAddress? destination
});


$RatrixAddressCopyWith<$Res>? get origin;$RatrixAddressCopyWith<$Res>? get destination;

}
/// @nodoc
class _$RatrixRouteCopyWithImpl<$Res>
    implements $RatrixRouteCopyWith<$Res> {
  _$RatrixRouteCopyWithImpl(this._self, this._then);

  final RatrixRoute _self;
  final $Res Function(RatrixRoute) _then;

/// Create a copy of RatrixRoute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? vehicleTypeId = freezed,Object? containerSizeId = freezed,Object? frequencyBasisId = freezed,Object? minDistance = freezed,Object? maxDistance = freezed,Object? numberOfTrips = freezed,Object? excessRate = freezed,Object? timeInHours = freezed,Object? rate = freezed,Object? breakweights = null,Object? origin = freezed,Object? destination = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,vehicleTypeId: freezed == vehicleTypeId ? _self.vehicleTypeId : vehicleTypeId // ignore: cast_nullable_to_non_nullable
as int?,containerSizeId: freezed == containerSizeId ? _self.containerSizeId : containerSizeId // ignore: cast_nullable_to_non_nullable
as int?,frequencyBasisId: freezed == frequencyBasisId ? _self.frequencyBasisId : frequencyBasisId // ignore: cast_nullable_to_non_nullable
as int?,minDistance: freezed == minDistance ? _self.minDistance : minDistance // ignore: cast_nullable_to_non_nullable
as num?,maxDistance: freezed == maxDistance ? _self.maxDistance : maxDistance // ignore: cast_nullable_to_non_nullable
as num?,numberOfTrips: freezed == numberOfTrips ? _self.numberOfTrips : numberOfTrips // ignore: cast_nullable_to_non_nullable
as int?,excessRate: freezed == excessRate ? _self.excessRate : excessRate // ignore: cast_nullable_to_non_nullable
as num?,timeInHours: freezed == timeInHours ? _self.timeInHours : timeInHours // ignore: cast_nullable_to_non_nullable
as num?,rate: freezed == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as num?,breakweights: null == breakweights ? _self.breakweights : breakweights // ignore: cast_nullable_to_non_nullable
as List<RatrixBreakweight>,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as RatrixAddress?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as RatrixAddress?,
  ));
}
/// Create a copy of RatrixRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatrixAddressCopyWith<$Res>? get origin {
    if (_self.origin == null) {
    return null;
  }

  return $RatrixAddressCopyWith<$Res>(_self.origin!, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of RatrixRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatrixAddressCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $RatrixAddressCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}


/// Adds pattern-matching-related methods to [RatrixRoute].
extension RatrixRoutePatterns on RatrixRoute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RatrixRoute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RatrixRoute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RatrixRoute value)  $default,){
final _that = this;
switch (_that) {
case _RatrixRoute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RatrixRoute value)?  $default,){
final _that = this;
switch (_that) {
case _RatrixRoute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  int? vehicleTypeId,  int? containerSizeId,  int? frequencyBasisId,  num? minDistance,  num? maxDistance,  int? numberOfTrips,  num? excessRate,  num? timeInHours,  num? rate,  List<RatrixBreakweight> breakweights,  RatrixAddress? origin,  RatrixAddress? destination)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RatrixRoute() when $default != null:
return $default(_that.id,_that.vehicleTypeId,_that.containerSizeId,_that.frequencyBasisId,_that.minDistance,_that.maxDistance,_that.numberOfTrips,_that.excessRate,_that.timeInHours,_that.rate,_that.breakweights,_that.origin,_that.destination);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  int? vehicleTypeId,  int? containerSizeId,  int? frequencyBasisId,  num? minDistance,  num? maxDistance,  int? numberOfTrips,  num? excessRate,  num? timeInHours,  num? rate,  List<RatrixBreakweight> breakweights,  RatrixAddress? origin,  RatrixAddress? destination)  $default,) {final _that = this;
switch (_that) {
case _RatrixRoute():
return $default(_that.id,_that.vehicleTypeId,_that.containerSizeId,_that.frequencyBasisId,_that.minDistance,_that.maxDistance,_that.numberOfTrips,_that.excessRate,_that.timeInHours,_that.rate,_that.breakweights,_that.origin,_that.destination);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  int? vehicleTypeId,  int? containerSizeId,  int? frequencyBasisId,  num? minDistance,  num? maxDistance,  int? numberOfTrips,  num? excessRate,  num? timeInHours,  num? rate,  List<RatrixBreakweight> breakweights,  RatrixAddress? origin,  RatrixAddress? destination)?  $default,) {final _that = this;
switch (_that) {
case _RatrixRoute() when $default != null:
return $default(_that.id,_that.vehicleTypeId,_that.containerSizeId,_that.frequencyBasisId,_that.minDistance,_that.maxDistance,_that.numberOfTrips,_that.excessRate,_that.timeInHours,_that.rate,_that.breakweights,_that.origin,_that.destination);case _:
  return null;

}
}

}

/// @nodoc


class _RatrixRoute extends RatrixRoute {
  const _RatrixRoute({this.id, this.vehicleTypeId, this.containerSizeId, this.frequencyBasisId, this.minDistance, this.maxDistance, this.numberOfTrips, this.excessRate, this.timeInHours, this.rate, final  List<RatrixBreakweight> breakweights = const <RatrixBreakweight>[], this.origin, this.destination}): _breakweights = breakweights,super._();
  

@override final  String? id;
@override final  int? vehicleTypeId;
@override final  int? containerSizeId;
@override final  int? frequencyBasisId;
@override final  num? minDistance;
@override final  num? maxDistance;
@override final  int? numberOfTrips;
@override final  num? excessRate;
@override final  num? timeInHours;
@override final  num? rate;
 final  List<RatrixBreakweight> _breakweights;
@override@JsonKey() List<RatrixBreakweight> get breakweights {
  if (_breakweights is EqualUnmodifiableListView) return _breakweights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_breakweights);
}

@override final  RatrixAddress? origin;
@override final  RatrixAddress? destination;

/// Create a copy of RatrixRoute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RatrixRouteCopyWith<_RatrixRoute> get copyWith => __$RatrixRouteCopyWithImpl<_RatrixRoute>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RatrixRoute&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleTypeId, vehicleTypeId) || other.vehicleTypeId == vehicleTypeId)&&(identical(other.containerSizeId, containerSizeId) || other.containerSizeId == containerSizeId)&&(identical(other.frequencyBasisId, frequencyBasisId) || other.frequencyBasisId == frequencyBasisId)&&(identical(other.minDistance, minDistance) || other.minDistance == minDistance)&&(identical(other.maxDistance, maxDistance) || other.maxDistance == maxDistance)&&(identical(other.numberOfTrips, numberOfTrips) || other.numberOfTrips == numberOfTrips)&&(identical(other.excessRate, excessRate) || other.excessRate == excessRate)&&(identical(other.timeInHours, timeInHours) || other.timeInHours == timeInHours)&&(identical(other.rate, rate) || other.rate == rate)&&const DeepCollectionEquality().equals(other._breakweights, _breakweights)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination));
}


@override
int get hashCode => Object.hash(runtimeType,id,vehicleTypeId,containerSizeId,frequencyBasisId,minDistance,maxDistance,numberOfTrips,excessRate,timeInHours,rate,const DeepCollectionEquality().hash(_breakweights),origin,destination);

@override
String toString() {
  return 'RatrixRoute(id: $id, vehicleTypeId: $vehicleTypeId, containerSizeId: $containerSizeId, frequencyBasisId: $frequencyBasisId, minDistance: $minDistance, maxDistance: $maxDistance, numberOfTrips: $numberOfTrips, excessRate: $excessRate, timeInHours: $timeInHours, rate: $rate, breakweights: $breakweights, origin: $origin, destination: $destination)';
}


}

/// @nodoc
abstract mixin class _$RatrixRouteCopyWith<$Res> implements $RatrixRouteCopyWith<$Res> {
  factory _$RatrixRouteCopyWith(_RatrixRoute value, $Res Function(_RatrixRoute) _then) = __$RatrixRouteCopyWithImpl;
@override @useResult
$Res call({
 String? id, int? vehicleTypeId, int? containerSizeId, int? frequencyBasisId, num? minDistance, num? maxDistance, int? numberOfTrips, num? excessRate, num? timeInHours, num? rate, List<RatrixBreakweight> breakweights, RatrixAddress? origin, RatrixAddress? destination
});


@override $RatrixAddressCopyWith<$Res>? get origin;@override $RatrixAddressCopyWith<$Res>? get destination;

}
/// @nodoc
class __$RatrixRouteCopyWithImpl<$Res>
    implements _$RatrixRouteCopyWith<$Res> {
  __$RatrixRouteCopyWithImpl(this._self, this._then);

  final _RatrixRoute _self;
  final $Res Function(_RatrixRoute) _then;

/// Create a copy of RatrixRoute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? vehicleTypeId = freezed,Object? containerSizeId = freezed,Object? frequencyBasisId = freezed,Object? minDistance = freezed,Object? maxDistance = freezed,Object? numberOfTrips = freezed,Object? excessRate = freezed,Object? timeInHours = freezed,Object? rate = freezed,Object? breakweights = null,Object? origin = freezed,Object? destination = freezed,}) {
  return _then(_RatrixRoute(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,vehicleTypeId: freezed == vehicleTypeId ? _self.vehicleTypeId : vehicleTypeId // ignore: cast_nullable_to_non_nullable
as int?,containerSizeId: freezed == containerSizeId ? _self.containerSizeId : containerSizeId // ignore: cast_nullable_to_non_nullable
as int?,frequencyBasisId: freezed == frequencyBasisId ? _self.frequencyBasisId : frequencyBasisId // ignore: cast_nullable_to_non_nullable
as int?,minDistance: freezed == minDistance ? _self.minDistance : minDistance // ignore: cast_nullable_to_non_nullable
as num?,maxDistance: freezed == maxDistance ? _self.maxDistance : maxDistance // ignore: cast_nullable_to_non_nullable
as num?,numberOfTrips: freezed == numberOfTrips ? _self.numberOfTrips : numberOfTrips // ignore: cast_nullable_to_non_nullable
as int?,excessRate: freezed == excessRate ? _self.excessRate : excessRate // ignore: cast_nullable_to_non_nullable
as num?,timeInHours: freezed == timeInHours ? _self.timeInHours : timeInHours // ignore: cast_nullable_to_non_nullable
as num?,rate: freezed == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as num?,breakweights: null == breakweights ? _self._breakweights : breakweights // ignore: cast_nullable_to_non_nullable
as List<RatrixBreakweight>,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as RatrixAddress?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as RatrixAddress?,
  ));
}

/// Create a copy of RatrixRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatrixAddressCopyWith<$Res>? get origin {
    if (_self.origin == null) {
    return null;
  }

  return $RatrixAddressCopyWith<$Res>(_self.origin!, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of RatrixRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatrixAddressCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $RatrixAddressCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}

/// @nodoc
mixin _$RatrixAddons {

 num? get baseFreightRate; num? get fuelSurcharge; String? get fuelSurchargeType; num? get securitySurcharge; num? get oda; num? get waybillFee; num? get bookingHandlingFee; num? get documentationFee; num? get participationFee; num? get permitFeesNonVat; num? get insurance; num? get valuation; String? get valuationType; num? get pickupFee; num? get deliveryFee; num? get cratingFee; num? get packingFee; num? get airThc; num? get seaThc; num? get arrastre; num? get demurrageDetention; num? get waitingTime; num? get roadToll; num? get othersNonVat; num? get hazardousGoodsHandling; ConditionalAddonConfig? get odaConfig; ConditionalAddonConfig? get pickupFeeConfig;
/// Create a copy of RatrixAddons
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RatrixAddonsCopyWith<RatrixAddons> get copyWith => _$RatrixAddonsCopyWithImpl<RatrixAddons>(this as RatrixAddons, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RatrixAddons&&(identical(other.baseFreightRate, baseFreightRate) || other.baseFreightRate == baseFreightRate)&&(identical(other.fuelSurcharge, fuelSurcharge) || other.fuelSurcharge == fuelSurcharge)&&(identical(other.fuelSurchargeType, fuelSurchargeType) || other.fuelSurchargeType == fuelSurchargeType)&&(identical(other.securitySurcharge, securitySurcharge) || other.securitySurcharge == securitySurcharge)&&(identical(other.oda, oda) || other.oda == oda)&&(identical(other.waybillFee, waybillFee) || other.waybillFee == waybillFee)&&(identical(other.bookingHandlingFee, bookingHandlingFee) || other.bookingHandlingFee == bookingHandlingFee)&&(identical(other.documentationFee, documentationFee) || other.documentationFee == documentationFee)&&(identical(other.participationFee, participationFee) || other.participationFee == participationFee)&&(identical(other.permitFeesNonVat, permitFeesNonVat) || other.permitFeesNonVat == permitFeesNonVat)&&(identical(other.insurance, insurance) || other.insurance == insurance)&&(identical(other.valuation, valuation) || other.valuation == valuation)&&(identical(other.valuationType, valuationType) || other.valuationType == valuationType)&&(identical(other.pickupFee, pickupFee) || other.pickupFee == pickupFee)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.cratingFee, cratingFee) || other.cratingFee == cratingFee)&&(identical(other.packingFee, packingFee) || other.packingFee == packingFee)&&(identical(other.airThc, airThc) || other.airThc == airThc)&&(identical(other.seaThc, seaThc) || other.seaThc == seaThc)&&(identical(other.arrastre, arrastre) || other.arrastre == arrastre)&&(identical(other.demurrageDetention, demurrageDetention) || other.demurrageDetention == demurrageDetention)&&(identical(other.waitingTime, waitingTime) || other.waitingTime == waitingTime)&&(identical(other.roadToll, roadToll) || other.roadToll == roadToll)&&(identical(other.othersNonVat, othersNonVat) || other.othersNonVat == othersNonVat)&&(identical(other.hazardousGoodsHandling, hazardousGoodsHandling) || other.hazardousGoodsHandling == hazardousGoodsHandling)&&(identical(other.odaConfig, odaConfig) || other.odaConfig == odaConfig)&&(identical(other.pickupFeeConfig, pickupFeeConfig) || other.pickupFeeConfig == pickupFeeConfig));
}


@override
int get hashCode => Object.hashAll([runtimeType,baseFreightRate,fuelSurcharge,fuelSurchargeType,securitySurcharge,oda,waybillFee,bookingHandlingFee,documentationFee,participationFee,permitFeesNonVat,insurance,valuation,valuationType,pickupFee,deliveryFee,cratingFee,packingFee,airThc,seaThc,arrastre,demurrageDetention,waitingTime,roadToll,othersNonVat,hazardousGoodsHandling,odaConfig,pickupFeeConfig]);

@override
String toString() {
  return 'RatrixAddons(baseFreightRate: $baseFreightRate, fuelSurcharge: $fuelSurcharge, fuelSurchargeType: $fuelSurchargeType, securitySurcharge: $securitySurcharge, oda: $oda, waybillFee: $waybillFee, bookingHandlingFee: $bookingHandlingFee, documentationFee: $documentationFee, participationFee: $participationFee, permitFeesNonVat: $permitFeesNonVat, insurance: $insurance, valuation: $valuation, valuationType: $valuationType, pickupFee: $pickupFee, deliveryFee: $deliveryFee, cratingFee: $cratingFee, packingFee: $packingFee, airThc: $airThc, seaThc: $seaThc, arrastre: $arrastre, demurrageDetention: $demurrageDetention, waitingTime: $waitingTime, roadToll: $roadToll, othersNonVat: $othersNonVat, hazardousGoodsHandling: $hazardousGoodsHandling, odaConfig: $odaConfig, pickupFeeConfig: $pickupFeeConfig)';
}


}

/// @nodoc
abstract mixin class $RatrixAddonsCopyWith<$Res>  {
  factory $RatrixAddonsCopyWith(RatrixAddons value, $Res Function(RatrixAddons) _then) = _$RatrixAddonsCopyWithImpl;
@useResult
$Res call({
 num? baseFreightRate, num? fuelSurcharge, String? fuelSurchargeType, num? securitySurcharge, num? oda, num? waybillFee, num? bookingHandlingFee, num? documentationFee, num? participationFee, num? permitFeesNonVat, num? insurance, num? valuation, String? valuationType, num? pickupFee, num? deliveryFee, num? cratingFee, num? packingFee, num? airThc, num? seaThc, num? arrastre, num? demurrageDetention, num? waitingTime, num? roadToll, num? othersNonVat, num? hazardousGoodsHandling, ConditionalAddonConfig? odaConfig, ConditionalAddonConfig? pickupFeeConfig
});




}
/// @nodoc
class _$RatrixAddonsCopyWithImpl<$Res>
    implements $RatrixAddonsCopyWith<$Res> {
  _$RatrixAddonsCopyWithImpl(this._self, this._then);

  final RatrixAddons _self;
  final $Res Function(RatrixAddons) _then;

/// Create a copy of RatrixAddons
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? baseFreightRate = freezed,Object? fuelSurcharge = freezed,Object? fuelSurchargeType = freezed,Object? securitySurcharge = freezed,Object? oda = freezed,Object? waybillFee = freezed,Object? bookingHandlingFee = freezed,Object? documentationFee = freezed,Object? participationFee = freezed,Object? permitFeesNonVat = freezed,Object? insurance = freezed,Object? valuation = freezed,Object? valuationType = freezed,Object? pickupFee = freezed,Object? deliveryFee = freezed,Object? cratingFee = freezed,Object? packingFee = freezed,Object? airThc = freezed,Object? seaThc = freezed,Object? arrastre = freezed,Object? demurrageDetention = freezed,Object? waitingTime = freezed,Object? roadToll = freezed,Object? othersNonVat = freezed,Object? hazardousGoodsHandling = freezed,Object? odaConfig = freezed,Object? pickupFeeConfig = freezed,}) {
  return _then(_self.copyWith(
baseFreightRate: freezed == baseFreightRate ? _self.baseFreightRate : baseFreightRate // ignore: cast_nullable_to_non_nullable
as num?,fuelSurcharge: freezed == fuelSurcharge ? _self.fuelSurcharge : fuelSurcharge // ignore: cast_nullable_to_non_nullable
as num?,fuelSurchargeType: freezed == fuelSurchargeType ? _self.fuelSurchargeType : fuelSurchargeType // ignore: cast_nullable_to_non_nullable
as String?,securitySurcharge: freezed == securitySurcharge ? _self.securitySurcharge : securitySurcharge // ignore: cast_nullable_to_non_nullable
as num?,oda: freezed == oda ? _self.oda : oda // ignore: cast_nullable_to_non_nullable
as num?,waybillFee: freezed == waybillFee ? _self.waybillFee : waybillFee // ignore: cast_nullable_to_non_nullable
as num?,bookingHandlingFee: freezed == bookingHandlingFee ? _self.bookingHandlingFee : bookingHandlingFee // ignore: cast_nullable_to_non_nullable
as num?,documentationFee: freezed == documentationFee ? _self.documentationFee : documentationFee // ignore: cast_nullable_to_non_nullable
as num?,participationFee: freezed == participationFee ? _self.participationFee : participationFee // ignore: cast_nullable_to_non_nullable
as num?,permitFeesNonVat: freezed == permitFeesNonVat ? _self.permitFeesNonVat : permitFeesNonVat // ignore: cast_nullable_to_non_nullable
as num?,insurance: freezed == insurance ? _self.insurance : insurance // ignore: cast_nullable_to_non_nullable
as num?,valuation: freezed == valuation ? _self.valuation : valuation // ignore: cast_nullable_to_non_nullable
as num?,valuationType: freezed == valuationType ? _self.valuationType : valuationType // ignore: cast_nullable_to_non_nullable
as String?,pickupFee: freezed == pickupFee ? _self.pickupFee : pickupFee // ignore: cast_nullable_to_non_nullable
as num?,deliveryFee: freezed == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as num?,cratingFee: freezed == cratingFee ? _self.cratingFee : cratingFee // ignore: cast_nullable_to_non_nullable
as num?,packingFee: freezed == packingFee ? _self.packingFee : packingFee // ignore: cast_nullable_to_non_nullable
as num?,airThc: freezed == airThc ? _self.airThc : airThc // ignore: cast_nullable_to_non_nullable
as num?,seaThc: freezed == seaThc ? _self.seaThc : seaThc // ignore: cast_nullable_to_non_nullable
as num?,arrastre: freezed == arrastre ? _self.arrastre : arrastre // ignore: cast_nullable_to_non_nullable
as num?,demurrageDetention: freezed == demurrageDetention ? _self.demurrageDetention : demurrageDetention // ignore: cast_nullable_to_non_nullable
as num?,waitingTime: freezed == waitingTime ? _self.waitingTime : waitingTime // ignore: cast_nullable_to_non_nullable
as num?,roadToll: freezed == roadToll ? _self.roadToll : roadToll // ignore: cast_nullable_to_non_nullable
as num?,othersNonVat: freezed == othersNonVat ? _self.othersNonVat : othersNonVat // ignore: cast_nullable_to_non_nullable
as num?,hazardousGoodsHandling: freezed == hazardousGoodsHandling ? _self.hazardousGoodsHandling : hazardousGoodsHandling // ignore: cast_nullable_to_non_nullable
as num?,odaConfig: freezed == odaConfig ? _self.odaConfig : odaConfig // ignore: cast_nullable_to_non_nullable
as ConditionalAddonConfig?,pickupFeeConfig: freezed == pickupFeeConfig ? _self.pickupFeeConfig : pickupFeeConfig // ignore: cast_nullable_to_non_nullable
as ConditionalAddonConfig?,
  ));
}

}


/// Adds pattern-matching-related methods to [RatrixAddons].
extension RatrixAddonsPatterns on RatrixAddons {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RatrixAddons value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RatrixAddons() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RatrixAddons value)  $default,){
final _that = this;
switch (_that) {
case _RatrixAddons():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RatrixAddons value)?  $default,){
final _that = this;
switch (_that) {
case _RatrixAddons() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num? baseFreightRate,  num? fuelSurcharge,  String? fuelSurchargeType,  num? securitySurcharge,  num? oda,  num? waybillFee,  num? bookingHandlingFee,  num? documentationFee,  num? participationFee,  num? permitFeesNonVat,  num? insurance,  num? valuation,  String? valuationType,  num? pickupFee,  num? deliveryFee,  num? cratingFee,  num? packingFee,  num? airThc,  num? seaThc,  num? arrastre,  num? demurrageDetention,  num? waitingTime,  num? roadToll,  num? othersNonVat,  num? hazardousGoodsHandling,  ConditionalAddonConfig? odaConfig,  ConditionalAddonConfig? pickupFeeConfig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RatrixAddons() when $default != null:
return $default(_that.baseFreightRate,_that.fuelSurcharge,_that.fuelSurchargeType,_that.securitySurcharge,_that.oda,_that.waybillFee,_that.bookingHandlingFee,_that.documentationFee,_that.participationFee,_that.permitFeesNonVat,_that.insurance,_that.valuation,_that.valuationType,_that.pickupFee,_that.deliveryFee,_that.cratingFee,_that.packingFee,_that.airThc,_that.seaThc,_that.arrastre,_that.demurrageDetention,_that.waitingTime,_that.roadToll,_that.othersNonVat,_that.hazardousGoodsHandling,_that.odaConfig,_that.pickupFeeConfig);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num? baseFreightRate,  num? fuelSurcharge,  String? fuelSurchargeType,  num? securitySurcharge,  num? oda,  num? waybillFee,  num? bookingHandlingFee,  num? documentationFee,  num? participationFee,  num? permitFeesNonVat,  num? insurance,  num? valuation,  String? valuationType,  num? pickupFee,  num? deliveryFee,  num? cratingFee,  num? packingFee,  num? airThc,  num? seaThc,  num? arrastre,  num? demurrageDetention,  num? waitingTime,  num? roadToll,  num? othersNonVat,  num? hazardousGoodsHandling,  ConditionalAddonConfig? odaConfig,  ConditionalAddonConfig? pickupFeeConfig)  $default,) {final _that = this;
switch (_that) {
case _RatrixAddons():
return $default(_that.baseFreightRate,_that.fuelSurcharge,_that.fuelSurchargeType,_that.securitySurcharge,_that.oda,_that.waybillFee,_that.bookingHandlingFee,_that.documentationFee,_that.participationFee,_that.permitFeesNonVat,_that.insurance,_that.valuation,_that.valuationType,_that.pickupFee,_that.deliveryFee,_that.cratingFee,_that.packingFee,_that.airThc,_that.seaThc,_that.arrastre,_that.demurrageDetention,_that.waitingTime,_that.roadToll,_that.othersNonVat,_that.hazardousGoodsHandling,_that.odaConfig,_that.pickupFeeConfig);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num? baseFreightRate,  num? fuelSurcharge,  String? fuelSurchargeType,  num? securitySurcharge,  num? oda,  num? waybillFee,  num? bookingHandlingFee,  num? documentationFee,  num? participationFee,  num? permitFeesNonVat,  num? insurance,  num? valuation,  String? valuationType,  num? pickupFee,  num? deliveryFee,  num? cratingFee,  num? packingFee,  num? airThc,  num? seaThc,  num? arrastre,  num? demurrageDetention,  num? waitingTime,  num? roadToll,  num? othersNonVat,  num? hazardousGoodsHandling,  ConditionalAddonConfig? odaConfig,  ConditionalAddonConfig? pickupFeeConfig)?  $default,) {final _that = this;
switch (_that) {
case _RatrixAddons() when $default != null:
return $default(_that.baseFreightRate,_that.fuelSurcharge,_that.fuelSurchargeType,_that.securitySurcharge,_that.oda,_that.waybillFee,_that.bookingHandlingFee,_that.documentationFee,_that.participationFee,_that.permitFeesNonVat,_that.insurance,_that.valuation,_that.valuationType,_that.pickupFee,_that.deliveryFee,_that.cratingFee,_that.packingFee,_that.airThc,_that.seaThc,_that.arrastre,_that.demurrageDetention,_that.waitingTime,_that.roadToll,_that.othersNonVat,_that.hazardousGoodsHandling,_that.odaConfig,_that.pickupFeeConfig);case _:
  return null;

}
}

}

/// @nodoc


class _RatrixAddons extends RatrixAddons {
  const _RatrixAddons({this.baseFreightRate, this.fuelSurcharge, this.fuelSurchargeType, this.securitySurcharge, this.oda, this.waybillFee, this.bookingHandlingFee, this.documentationFee, this.participationFee, this.permitFeesNonVat, this.insurance, this.valuation, this.valuationType, this.pickupFee, this.deliveryFee, this.cratingFee, this.packingFee, this.airThc, this.seaThc, this.arrastre, this.demurrageDetention, this.waitingTime, this.roadToll, this.othersNonVat, this.hazardousGoodsHandling, this.odaConfig, this.pickupFeeConfig}): super._();
  

@override final  num? baseFreightRate;
@override final  num? fuelSurcharge;
@override final  String? fuelSurchargeType;
@override final  num? securitySurcharge;
@override final  num? oda;
@override final  num? waybillFee;
@override final  num? bookingHandlingFee;
@override final  num? documentationFee;
@override final  num? participationFee;
@override final  num? permitFeesNonVat;
@override final  num? insurance;
@override final  num? valuation;
@override final  String? valuationType;
@override final  num? pickupFee;
@override final  num? deliveryFee;
@override final  num? cratingFee;
@override final  num? packingFee;
@override final  num? airThc;
@override final  num? seaThc;
@override final  num? arrastre;
@override final  num? demurrageDetention;
@override final  num? waitingTime;
@override final  num? roadToll;
@override final  num? othersNonVat;
@override final  num? hazardousGoodsHandling;
@override final  ConditionalAddonConfig? odaConfig;
@override final  ConditionalAddonConfig? pickupFeeConfig;

/// Create a copy of RatrixAddons
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RatrixAddonsCopyWith<_RatrixAddons> get copyWith => __$RatrixAddonsCopyWithImpl<_RatrixAddons>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RatrixAddons&&(identical(other.baseFreightRate, baseFreightRate) || other.baseFreightRate == baseFreightRate)&&(identical(other.fuelSurcharge, fuelSurcharge) || other.fuelSurcharge == fuelSurcharge)&&(identical(other.fuelSurchargeType, fuelSurchargeType) || other.fuelSurchargeType == fuelSurchargeType)&&(identical(other.securitySurcharge, securitySurcharge) || other.securitySurcharge == securitySurcharge)&&(identical(other.oda, oda) || other.oda == oda)&&(identical(other.waybillFee, waybillFee) || other.waybillFee == waybillFee)&&(identical(other.bookingHandlingFee, bookingHandlingFee) || other.bookingHandlingFee == bookingHandlingFee)&&(identical(other.documentationFee, documentationFee) || other.documentationFee == documentationFee)&&(identical(other.participationFee, participationFee) || other.participationFee == participationFee)&&(identical(other.permitFeesNonVat, permitFeesNonVat) || other.permitFeesNonVat == permitFeesNonVat)&&(identical(other.insurance, insurance) || other.insurance == insurance)&&(identical(other.valuation, valuation) || other.valuation == valuation)&&(identical(other.valuationType, valuationType) || other.valuationType == valuationType)&&(identical(other.pickupFee, pickupFee) || other.pickupFee == pickupFee)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.cratingFee, cratingFee) || other.cratingFee == cratingFee)&&(identical(other.packingFee, packingFee) || other.packingFee == packingFee)&&(identical(other.airThc, airThc) || other.airThc == airThc)&&(identical(other.seaThc, seaThc) || other.seaThc == seaThc)&&(identical(other.arrastre, arrastre) || other.arrastre == arrastre)&&(identical(other.demurrageDetention, demurrageDetention) || other.demurrageDetention == demurrageDetention)&&(identical(other.waitingTime, waitingTime) || other.waitingTime == waitingTime)&&(identical(other.roadToll, roadToll) || other.roadToll == roadToll)&&(identical(other.othersNonVat, othersNonVat) || other.othersNonVat == othersNonVat)&&(identical(other.hazardousGoodsHandling, hazardousGoodsHandling) || other.hazardousGoodsHandling == hazardousGoodsHandling)&&(identical(other.odaConfig, odaConfig) || other.odaConfig == odaConfig)&&(identical(other.pickupFeeConfig, pickupFeeConfig) || other.pickupFeeConfig == pickupFeeConfig));
}


@override
int get hashCode => Object.hashAll([runtimeType,baseFreightRate,fuelSurcharge,fuelSurchargeType,securitySurcharge,oda,waybillFee,bookingHandlingFee,documentationFee,participationFee,permitFeesNonVat,insurance,valuation,valuationType,pickupFee,deliveryFee,cratingFee,packingFee,airThc,seaThc,arrastre,demurrageDetention,waitingTime,roadToll,othersNonVat,hazardousGoodsHandling,odaConfig,pickupFeeConfig]);

@override
String toString() {
  return 'RatrixAddons(baseFreightRate: $baseFreightRate, fuelSurcharge: $fuelSurcharge, fuelSurchargeType: $fuelSurchargeType, securitySurcharge: $securitySurcharge, oda: $oda, waybillFee: $waybillFee, bookingHandlingFee: $bookingHandlingFee, documentationFee: $documentationFee, participationFee: $participationFee, permitFeesNonVat: $permitFeesNonVat, insurance: $insurance, valuation: $valuation, valuationType: $valuationType, pickupFee: $pickupFee, deliveryFee: $deliveryFee, cratingFee: $cratingFee, packingFee: $packingFee, airThc: $airThc, seaThc: $seaThc, arrastre: $arrastre, demurrageDetention: $demurrageDetention, waitingTime: $waitingTime, roadToll: $roadToll, othersNonVat: $othersNonVat, hazardousGoodsHandling: $hazardousGoodsHandling, odaConfig: $odaConfig, pickupFeeConfig: $pickupFeeConfig)';
}


}

/// @nodoc
abstract mixin class _$RatrixAddonsCopyWith<$Res> implements $RatrixAddonsCopyWith<$Res> {
  factory _$RatrixAddonsCopyWith(_RatrixAddons value, $Res Function(_RatrixAddons) _then) = __$RatrixAddonsCopyWithImpl;
@override @useResult
$Res call({
 num? baseFreightRate, num? fuelSurcharge, String? fuelSurchargeType, num? securitySurcharge, num? oda, num? waybillFee, num? bookingHandlingFee, num? documentationFee, num? participationFee, num? permitFeesNonVat, num? insurance, num? valuation, String? valuationType, num? pickupFee, num? deliveryFee, num? cratingFee, num? packingFee, num? airThc, num? seaThc, num? arrastre, num? demurrageDetention, num? waitingTime, num? roadToll, num? othersNonVat, num? hazardousGoodsHandling, ConditionalAddonConfig? odaConfig, ConditionalAddonConfig? pickupFeeConfig
});




}
/// @nodoc
class __$RatrixAddonsCopyWithImpl<$Res>
    implements _$RatrixAddonsCopyWith<$Res> {
  __$RatrixAddonsCopyWithImpl(this._self, this._then);

  final _RatrixAddons _self;
  final $Res Function(_RatrixAddons) _then;

/// Create a copy of RatrixAddons
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? baseFreightRate = freezed,Object? fuelSurcharge = freezed,Object? fuelSurchargeType = freezed,Object? securitySurcharge = freezed,Object? oda = freezed,Object? waybillFee = freezed,Object? bookingHandlingFee = freezed,Object? documentationFee = freezed,Object? participationFee = freezed,Object? permitFeesNonVat = freezed,Object? insurance = freezed,Object? valuation = freezed,Object? valuationType = freezed,Object? pickupFee = freezed,Object? deliveryFee = freezed,Object? cratingFee = freezed,Object? packingFee = freezed,Object? airThc = freezed,Object? seaThc = freezed,Object? arrastre = freezed,Object? demurrageDetention = freezed,Object? waitingTime = freezed,Object? roadToll = freezed,Object? othersNonVat = freezed,Object? hazardousGoodsHandling = freezed,Object? odaConfig = freezed,Object? pickupFeeConfig = freezed,}) {
  return _then(_RatrixAddons(
baseFreightRate: freezed == baseFreightRate ? _self.baseFreightRate : baseFreightRate // ignore: cast_nullable_to_non_nullable
as num?,fuelSurcharge: freezed == fuelSurcharge ? _self.fuelSurcharge : fuelSurcharge // ignore: cast_nullable_to_non_nullable
as num?,fuelSurchargeType: freezed == fuelSurchargeType ? _self.fuelSurchargeType : fuelSurchargeType // ignore: cast_nullable_to_non_nullable
as String?,securitySurcharge: freezed == securitySurcharge ? _self.securitySurcharge : securitySurcharge // ignore: cast_nullable_to_non_nullable
as num?,oda: freezed == oda ? _self.oda : oda // ignore: cast_nullable_to_non_nullable
as num?,waybillFee: freezed == waybillFee ? _self.waybillFee : waybillFee // ignore: cast_nullable_to_non_nullable
as num?,bookingHandlingFee: freezed == bookingHandlingFee ? _self.bookingHandlingFee : bookingHandlingFee // ignore: cast_nullable_to_non_nullable
as num?,documentationFee: freezed == documentationFee ? _self.documentationFee : documentationFee // ignore: cast_nullable_to_non_nullable
as num?,participationFee: freezed == participationFee ? _self.participationFee : participationFee // ignore: cast_nullable_to_non_nullable
as num?,permitFeesNonVat: freezed == permitFeesNonVat ? _self.permitFeesNonVat : permitFeesNonVat // ignore: cast_nullable_to_non_nullable
as num?,insurance: freezed == insurance ? _self.insurance : insurance // ignore: cast_nullable_to_non_nullable
as num?,valuation: freezed == valuation ? _self.valuation : valuation // ignore: cast_nullable_to_non_nullable
as num?,valuationType: freezed == valuationType ? _self.valuationType : valuationType // ignore: cast_nullable_to_non_nullable
as String?,pickupFee: freezed == pickupFee ? _self.pickupFee : pickupFee // ignore: cast_nullable_to_non_nullable
as num?,deliveryFee: freezed == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as num?,cratingFee: freezed == cratingFee ? _self.cratingFee : cratingFee // ignore: cast_nullable_to_non_nullable
as num?,packingFee: freezed == packingFee ? _self.packingFee : packingFee // ignore: cast_nullable_to_non_nullable
as num?,airThc: freezed == airThc ? _self.airThc : airThc // ignore: cast_nullable_to_non_nullable
as num?,seaThc: freezed == seaThc ? _self.seaThc : seaThc // ignore: cast_nullable_to_non_nullable
as num?,arrastre: freezed == arrastre ? _self.arrastre : arrastre // ignore: cast_nullable_to_non_nullable
as num?,demurrageDetention: freezed == demurrageDetention ? _self.demurrageDetention : demurrageDetention // ignore: cast_nullable_to_non_nullable
as num?,waitingTime: freezed == waitingTime ? _self.waitingTime : waitingTime // ignore: cast_nullable_to_non_nullable
as num?,roadToll: freezed == roadToll ? _self.roadToll : roadToll // ignore: cast_nullable_to_non_nullable
as num?,othersNonVat: freezed == othersNonVat ? _self.othersNonVat : othersNonVat // ignore: cast_nullable_to_non_nullable
as num?,hazardousGoodsHandling: freezed == hazardousGoodsHandling ? _self.hazardousGoodsHandling : hazardousGoodsHandling // ignore: cast_nullable_to_non_nullable
as num?,odaConfig: freezed == odaConfig ? _self.odaConfig : odaConfig // ignore: cast_nullable_to_non_nullable
as ConditionalAddonConfig?,pickupFeeConfig: freezed == pickupFeeConfig ? _self.pickupFeeConfig : pickupFeeConfig // ignore: cast_nullable_to_non_nullable
as ConditionalAddonConfig?,
  ));
}


}

/// @nodoc
mixin _$RatrixRate {

 String get id; String? get chargeCode; String get rateType; DateTime? get rateExpiry; int? get clientId; RatrixLookupOption? get freightMode; RatrixLookupOption? get serviceMode; RatrixLookupOption? get chargeOption; RatrixLookupOption? get chargeBasis; List<RatrixRoute> get routes; RatrixAddons? get addons; num? get expressMarkup; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of RatrixRate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RatrixRateCopyWith<RatrixRate> get copyWith => _$RatrixRateCopyWithImpl<RatrixRate>(this as RatrixRate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RatrixRate&&(identical(other.id, id) || other.id == id)&&(identical(other.chargeCode, chargeCode) || other.chargeCode == chargeCode)&&(identical(other.rateType, rateType) || other.rateType == rateType)&&(identical(other.rateExpiry, rateExpiry) || other.rateExpiry == rateExpiry)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.freightMode, freightMode) || other.freightMode == freightMode)&&(identical(other.serviceMode, serviceMode) || other.serviceMode == serviceMode)&&(identical(other.chargeOption, chargeOption) || other.chargeOption == chargeOption)&&(identical(other.chargeBasis, chargeBasis) || other.chargeBasis == chargeBasis)&&const DeepCollectionEquality().equals(other.routes, routes)&&(identical(other.addons, addons) || other.addons == addons)&&(identical(other.expressMarkup, expressMarkup) || other.expressMarkup == expressMarkup)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,chargeCode,rateType,rateExpiry,clientId,freightMode,serviceMode,chargeOption,chargeBasis,const DeepCollectionEquality().hash(routes),addons,expressMarkup,createdAt,updatedAt);

@override
String toString() {
  return 'RatrixRate(id: $id, chargeCode: $chargeCode, rateType: $rateType, rateExpiry: $rateExpiry, clientId: $clientId, freightMode: $freightMode, serviceMode: $serviceMode, chargeOption: $chargeOption, chargeBasis: $chargeBasis, routes: $routes, addons: $addons, expressMarkup: $expressMarkup, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RatrixRateCopyWith<$Res>  {
  factory $RatrixRateCopyWith(RatrixRate value, $Res Function(RatrixRate) _then) = _$RatrixRateCopyWithImpl;
@useResult
$Res call({
 String id, String? chargeCode, String rateType, DateTime? rateExpiry, int? clientId, RatrixLookupOption? freightMode, RatrixLookupOption? serviceMode, RatrixLookupOption? chargeOption, RatrixLookupOption? chargeBasis, List<RatrixRoute> routes, RatrixAddons? addons, num? expressMarkup, DateTime? createdAt, DateTime? updatedAt
});


$RatrixLookupOptionCopyWith<$Res>? get freightMode;$RatrixLookupOptionCopyWith<$Res>? get serviceMode;$RatrixLookupOptionCopyWith<$Res>? get chargeOption;$RatrixLookupOptionCopyWith<$Res>? get chargeBasis;$RatrixAddonsCopyWith<$Res>? get addons;

}
/// @nodoc
class _$RatrixRateCopyWithImpl<$Res>
    implements $RatrixRateCopyWith<$Res> {
  _$RatrixRateCopyWithImpl(this._self, this._then);

  final RatrixRate _self;
  final $Res Function(RatrixRate) _then;

/// Create a copy of RatrixRate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chargeCode = freezed,Object? rateType = null,Object? rateExpiry = freezed,Object? clientId = freezed,Object? freightMode = freezed,Object? serviceMode = freezed,Object? chargeOption = freezed,Object? chargeBasis = freezed,Object? routes = null,Object? addons = freezed,Object? expressMarkup = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chargeCode: freezed == chargeCode ? _self.chargeCode : chargeCode // ignore: cast_nullable_to_non_nullable
as String?,rateType: null == rateType ? _self.rateType : rateType // ignore: cast_nullable_to_non_nullable
as String,rateExpiry: freezed == rateExpiry ? _self.rateExpiry : rateExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as int?,freightMode: freezed == freightMode ? _self.freightMode : freightMode // ignore: cast_nullable_to_non_nullable
as RatrixLookupOption?,serviceMode: freezed == serviceMode ? _self.serviceMode : serviceMode // ignore: cast_nullable_to_non_nullable
as RatrixLookupOption?,chargeOption: freezed == chargeOption ? _self.chargeOption : chargeOption // ignore: cast_nullable_to_non_nullable
as RatrixLookupOption?,chargeBasis: freezed == chargeBasis ? _self.chargeBasis : chargeBasis // ignore: cast_nullable_to_non_nullable
as RatrixLookupOption?,routes: null == routes ? _self.routes : routes // ignore: cast_nullable_to_non_nullable
as List<RatrixRoute>,addons: freezed == addons ? _self.addons : addons // ignore: cast_nullable_to_non_nullable
as RatrixAddons?,expressMarkup: freezed == expressMarkup ? _self.expressMarkup : expressMarkup // ignore: cast_nullable_to_non_nullable
as num?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RatrixRate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatrixLookupOptionCopyWith<$Res>? get freightMode {
    if (_self.freightMode == null) {
    return null;
  }

  return $RatrixLookupOptionCopyWith<$Res>(_self.freightMode!, (value) {
    return _then(_self.copyWith(freightMode: value));
  });
}/// Create a copy of RatrixRate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatrixLookupOptionCopyWith<$Res>? get serviceMode {
    if (_self.serviceMode == null) {
    return null;
  }

  return $RatrixLookupOptionCopyWith<$Res>(_self.serviceMode!, (value) {
    return _then(_self.copyWith(serviceMode: value));
  });
}/// Create a copy of RatrixRate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatrixLookupOptionCopyWith<$Res>? get chargeOption {
    if (_self.chargeOption == null) {
    return null;
  }

  return $RatrixLookupOptionCopyWith<$Res>(_self.chargeOption!, (value) {
    return _then(_self.copyWith(chargeOption: value));
  });
}/// Create a copy of RatrixRate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatrixLookupOptionCopyWith<$Res>? get chargeBasis {
    if (_self.chargeBasis == null) {
    return null;
  }

  return $RatrixLookupOptionCopyWith<$Res>(_self.chargeBasis!, (value) {
    return _then(_self.copyWith(chargeBasis: value));
  });
}/// Create a copy of RatrixRate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatrixAddonsCopyWith<$Res>? get addons {
    if (_self.addons == null) {
    return null;
  }

  return $RatrixAddonsCopyWith<$Res>(_self.addons!, (value) {
    return _then(_self.copyWith(addons: value));
  });
}
}


/// Adds pattern-matching-related methods to [RatrixRate].
extension RatrixRatePatterns on RatrixRate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RatrixRate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RatrixRate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RatrixRate value)  $default,){
final _that = this;
switch (_that) {
case _RatrixRate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RatrixRate value)?  $default,){
final _that = this;
switch (_that) {
case _RatrixRate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? chargeCode,  String rateType,  DateTime? rateExpiry,  int? clientId,  RatrixLookupOption? freightMode,  RatrixLookupOption? serviceMode,  RatrixLookupOption? chargeOption,  RatrixLookupOption? chargeBasis,  List<RatrixRoute> routes,  RatrixAddons? addons,  num? expressMarkup,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RatrixRate() when $default != null:
return $default(_that.id,_that.chargeCode,_that.rateType,_that.rateExpiry,_that.clientId,_that.freightMode,_that.serviceMode,_that.chargeOption,_that.chargeBasis,_that.routes,_that.addons,_that.expressMarkup,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? chargeCode,  String rateType,  DateTime? rateExpiry,  int? clientId,  RatrixLookupOption? freightMode,  RatrixLookupOption? serviceMode,  RatrixLookupOption? chargeOption,  RatrixLookupOption? chargeBasis,  List<RatrixRoute> routes,  RatrixAddons? addons,  num? expressMarkup,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RatrixRate():
return $default(_that.id,_that.chargeCode,_that.rateType,_that.rateExpiry,_that.clientId,_that.freightMode,_that.serviceMode,_that.chargeOption,_that.chargeBasis,_that.routes,_that.addons,_that.expressMarkup,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? chargeCode,  String rateType,  DateTime? rateExpiry,  int? clientId,  RatrixLookupOption? freightMode,  RatrixLookupOption? serviceMode,  RatrixLookupOption? chargeOption,  RatrixLookupOption? chargeBasis,  List<RatrixRoute> routes,  RatrixAddons? addons,  num? expressMarkup,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RatrixRate() when $default != null:
return $default(_that.id,_that.chargeCode,_that.rateType,_that.rateExpiry,_that.clientId,_that.freightMode,_that.serviceMode,_that.chargeOption,_that.chargeBasis,_that.routes,_that.addons,_that.expressMarkup,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RatrixRate extends RatrixRate {
  const _RatrixRate({required this.id, this.chargeCode, required this.rateType, this.rateExpiry, this.clientId, this.freightMode, this.serviceMode, this.chargeOption, this.chargeBasis, final  List<RatrixRoute> routes = const <RatrixRoute>[], this.addons, this.expressMarkup, this.createdAt, this.updatedAt}): _routes = routes,super._();
  

@override final  String id;
@override final  String? chargeCode;
@override final  String rateType;
@override final  DateTime? rateExpiry;
@override final  int? clientId;
@override final  RatrixLookupOption? freightMode;
@override final  RatrixLookupOption? serviceMode;
@override final  RatrixLookupOption? chargeOption;
@override final  RatrixLookupOption? chargeBasis;
 final  List<RatrixRoute> _routes;
@override@JsonKey() List<RatrixRoute> get routes {
  if (_routes is EqualUnmodifiableListView) return _routes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routes);
}

@override final  RatrixAddons? addons;
@override final  num? expressMarkup;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of RatrixRate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RatrixRateCopyWith<_RatrixRate> get copyWith => __$RatrixRateCopyWithImpl<_RatrixRate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RatrixRate&&(identical(other.id, id) || other.id == id)&&(identical(other.chargeCode, chargeCode) || other.chargeCode == chargeCode)&&(identical(other.rateType, rateType) || other.rateType == rateType)&&(identical(other.rateExpiry, rateExpiry) || other.rateExpiry == rateExpiry)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.freightMode, freightMode) || other.freightMode == freightMode)&&(identical(other.serviceMode, serviceMode) || other.serviceMode == serviceMode)&&(identical(other.chargeOption, chargeOption) || other.chargeOption == chargeOption)&&(identical(other.chargeBasis, chargeBasis) || other.chargeBasis == chargeBasis)&&const DeepCollectionEquality().equals(other._routes, _routes)&&(identical(other.addons, addons) || other.addons == addons)&&(identical(other.expressMarkup, expressMarkup) || other.expressMarkup == expressMarkup)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,chargeCode,rateType,rateExpiry,clientId,freightMode,serviceMode,chargeOption,chargeBasis,const DeepCollectionEquality().hash(_routes),addons,expressMarkup,createdAt,updatedAt);

@override
String toString() {
  return 'RatrixRate(id: $id, chargeCode: $chargeCode, rateType: $rateType, rateExpiry: $rateExpiry, clientId: $clientId, freightMode: $freightMode, serviceMode: $serviceMode, chargeOption: $chargeOption, chargeBasis: $chargeBasis, routes: $routes, addons: $addons, expressMarkup: $expressMarkup, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RatrixRateCopyWith<$Res> implements $RatrixRateCopyWith<$Res> {
  factory _$RatrixRateCopyWith(_RatrixRate value, $Res Function(_RatrixRate) _then) = __$RatrixRateCopyWithImpl;
@override @useResult
$Res call({
 String id, String? chargeCode, String rateType, DateTime? rateExpiry, int? clientId, RatrixLookupOption? freightMode, RatrixLookupOption? serviceMode, RatrixLookupOption? chargeOption, RatrixLookupOption? chargeBasis, List<RatrixRoute> routes, RatrixAddons? addons, num? expressMarkup, DateTime? createdAt, DateTime? updatedAt
});


@override $RatrixLookupOptionCopyWith<$Res>? get freightMode;@override $RatrixLookupOptionCopyWith<$Res>? get serviceMode;@override $RatrixLookupOptionCopyWith<$Res>? get chargeOption;@override $RatrixLookupOptionCopyWith<$Res>? get chargeBasis;@override $RatrixAddonsCopyWith<$Res>? get addons;

}
/// @nodoc
class __$RatrixRateCopyWithImpl<$Res>
    implements _$RatrixRateCopyWith<$Res> {
  __$RatrixRateCopyWithImpl(this._self, this._then);

  final _RatrixRate _self;
  final $Res Function(_RatrixRate) _then;

/// Create a copy of RatrixRate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chargeCode = freezed,Object? rateType = null,Object? rateExpiry = freezed,Object? clientId = freezed,Object? freightMode = freezed,Object? serviceMode = freezed,Object? chargeOption = freezed,Object? chargeBasis = freezed,Object? routes = null,Object? addons = freezed,Object? expressMarkup = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_RatrixRate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chargeCode: freezed == chargeCode ? _self.chargeCode : chargeCode // ignore: cast_nullable_to_non_nullable
as String?,rateType: null == rateType ? _self.rateType : rateType // ignore: cast_nullable_to_non_nullable
as String,rateExpiry: freezed == rateExpiry ? _self.rateExpiry : rateExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as int?,freightMode: freezed == freightMode ? _self.freightMode : freightMode // ignore: cast_nullable_to_non_nullable
as RatrixLookupOption?,serviceMode: freezed == serviceMode ? _self.serviceMode : serviceMode // ignore: cast_nullable_to_non_nullable
as RatrixLookupOption?,chargeOption: freezed == chargeOption ? _self.chargeOption : chargeOption // ignore: cast_nullable_to_non_nullable
as RatrixLookupOption?,chargeBasis: freezed == chargeBasis ? _self.chargeBasis : chargeBasis // ignore: cast_nullable_to_non_nullable
as RatrixLookupOption?,routes: null == routes ? _self._routes : routes // ignore: cast_nullable_to_non_nullable
as List<RatrixRoute>,addons: freezed == addons ? _self.addons : addons // ignore: cast_nullable_to_non_nullable
as RatrixAddons?,expressMarkup: freezed == expressMarkup ? _self.expressMarkup : expressMarkup // ignore: cast_nullable_to_non_nullable
as num?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RatrixRate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatrixLookupOptionCopyWith<$Res>? get freightMode {
    if (_self.freightMode == null) {
    return null;
  }

  return $RatrixLookupOptionCopyWith<$Res>(_self.freightMode!, (value) {
    return _then(_self.copyWith(freightMode: value));
  });
}/// Create a copy of RatrixRate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatrixLookupOptionCopyWith<$Res>? get serviceMode {
    if (_self.serviceMode == null) {
    return null;
  }

  return $RatrixLookupOptionCopyWith<$Res>(_self.serviceMode!, (value) {
    return _then(_self.copyWith(serviceMode: value));
  });
}/// Create a copy of RatrixRate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatrixLookupOptionCopyWith<$Res>? get chargeOption {
    if (_self.chargeOption == null) {
    return null;
  }

  return $RatrixLookupOptionCopyWith<$Res>(_self.chargeOption!, (value) {
    return _then(_self.copyWith(chargeOption: value));
  });
}/// Create a copy of RatrixRate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatrixLookupOptionCopyWith<$Res>? get chargeBasis {
    if (_self.chargeBasis == null) {
    return null;
  }

  return $RatrixLookupOptionCopyWith<$Res>(_self.chargeBasis!, (value) {
    return _then(_self.copyWith(chargeBasis: value));
  });
}/// Create a copy of RatrixRate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatrixAddonsCopyWith<$Res>? get addons {
    if (_self.addons == null) {
    return null;
  }

  return $RatrixAddonsCopyWith<$Res>(_self.addons!, (value) {
    return _then(_self.copyWith(addons: value));
  });
}
}

// dart format on
