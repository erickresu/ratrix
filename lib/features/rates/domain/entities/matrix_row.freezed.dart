// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'matrix_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MatrixRow {

 String get origin; String get destination; List<String> get rates; String? get routeId; LocationOption? get originOption; LocationOption? get destinationOption;
/// Create a copy of MatrixRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatrixRowCopyWith<MatrixRow> get copyWith => _$MatrixRowCopyWithImpl<MatrixRow>(this as MatrixRow, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatrixRow&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&const DeepCollectionEquality().equals(other.rates, rates)&&(identical(other.routeId, routeId) || other.routeId == routeId)&&(identical(other.originOption, originOption) || other.originOption == originOption)&&(identical(other.destinationOption, destinationOption) || other.destinationOption == destinationOption));
}


@override
int get hashCode => Object.hash(runtimeType,origin,destination,const DeepCollectionEquality().hash(rates),routeId,originOption,destinationOption);

@override
String toString() {
  return 'MatrixRow(origin: $origin, destination: $destination, rates: $rates, routeId: $routeId, originOption: $originOption, destinationOption: $destinationOption)';
}


}

/// @nodoc
abstract mixin class $MatrixRowCopyWith<$Res>  {
  factory $MatrixRowCopyWith(MatrixRow value, $Res Function(MatrixRow) _then) = _$MatrixRowCopyWithImpl;
@useResult
$Res call({
 String origin, String destination, List<String> rates, String? routeId, LocationOption? originOption, LocationOption? destinationOption
});


$LocationOptionCopyWith<$Res>? get originOption;$LocationOptionCopyWith<$Res>? get destinationOption;

}
/// @nodoc
class _$MatrixRowCopyWithImpl<$Res>
    implements $MatrixRowCopyWith<$Res> {
  _$MatrixRowCopyWithImpl(this._self, this._then);

  final MatrixRow _self;
  final $Res Function(MatrixRow) _then;

/// Create a copy of MatrixRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? origin = null,Object? destination = null,Object? rates = null,Object? routeId = freezed,Object? originOption = freezed,Object? destinationOption = freezed,}) {
  return _then(_self.copyWith(
origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,rates: null == rates ? _self.rates : rates // ignore: cast_nullable_to_non_nullable
as List<String>,routeId: freezed == routeId ? _self.routeId : routeId // ignore: cast_nullable_to_non_nullable
as String?,originOption: freezed == originOption ? _self.originOption : originOption // ignore: cast_nullable_to_non_nullable
as LocationOption?,destinationOption: freezed == destinationOption ? _self.destinationOption : destinationOption // ignore: cast_nullable_to_non_nullable
as LocationOption?,
  ));
}
/// Create a copy of MatrixRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationOptionCopyWith<$Res>? get originOption {
    if (_self.originOption == null) {
    return null;
  }

  return $LocationOptionCopyWith<$Res>(_self.originOption!, (value) {
    return _then(_self.copyWith(originOption: value));
  });
}/// Create a copy of MatrixRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationOptionCopyWith<$Res>? get destinationOption {
    if (_self.destinationOption == null) {
    return null;
  }

  return $LocationOptionCopyWith<$Res>(_self.destinationOption!, (value) {
    return _then(_self.copyWith(destinationOption: value));
  });
}
}


/// Adds pattern-matching-related methods to [MatrixRow].
extension MatrixRowPatterns on MatrixRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatrixRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatrixRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatrixRow value)  $default,){
final _that = this;
switch (_that) {
case _MatrixRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatrixRow value)?  $default,){
final _that = this;
switch (_that) {
case _MatrixRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String origin,  String destination,  List<String> rates,  String? routeId,  LocationOption? originOption,  LocationOption? destinationOption)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatrixRow() when $default != null:
return $default(_that.origin,_that.destination,_that.rates,_that.routeId,_that.originOption,_that.destinationOption);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String origin,  String destination,  List<String> rates,  String? routeId,  LocationOption? originOption,  LocationOption? destinationOption)  $default,) {final _that = this;
switch (_that) {
case _MatrixRow():
return $default(_that.origin,_that.destination,_that.rates,_that.routeId,_that.originOption,_that.destinationOption);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String origin,  String destination,  List<String> rates,  String? routeId,  LocationOption? originOption,  LocationOption? destinationOption)?  $default,) {final _that = this;
switch (_that) {
case _MatrixRow() when $default != null:
return $default(_that.origin,_that.destination,_that.rates,_that.routeId,_that.originOption,_that.destinationOption);case _:
  return null;

}
}

}

/// @nodoc


class _MatrixRow implements MatrixRow {
  const _MatrixRow({this.origin = '', this.destination = '', final  List<String> rates = const <String>[''], this.routeId, this.originOption, this.destinationOption}): _rates = rates;
  

@override@JsonKey() final  String origin;
@override@JsonKey() final  String destination;
 final  List<String> _rates;
@override@JsonKey() List<String> get rates {
  if (_rates is EqualUnmodifiableListView) return _rates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rates);
}

@override final  String? routeId;
@override final  LocationOption? originOption;
@override final  LocationOption? destinationOption;

/// Create a copy of MatrixRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatrixRowCopyWith<_MatrixRow> get copyWith => __$MatrixRowCopyWithImpl<_MatrixRow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatrixRow&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&const DeepCollectionEquality().equals(other._rates, _rates)&&(identical(other.routeId, routeId) || other.routeId == routeId)&&(identical(other.originOption, originOption) || other.originOption == originOption)&&(identical(other.destinationOption, destinationOption) || other.destinationOption == destinationOption));
}


@override
int get hashCode => Object.hash(runtimeType,origin,destination,const DeepCollectionEquality().hash(_rates),routeId,originOption,destinationOption);

@override
String toString() {
  return 'MatrixRow(origin: $origin, destination: $destination, rates: $rates, routeId: $routeId, originOption: $originOption, destinationOption: $destinationOption)';
}


}

/// @nodoc
abstract mixin class _$MatrixRowCopyWith<$Res> implements $MatrixRowCopyWith<$Res> {
  factory _$MatrixRowCopyWith(_MatrixRow value, $Res Function(_MatrixRow) _then) = __$MatrixRowCopyWithImpl;
@override @useResult
$Res call({
 String origin, String destination, List<String> rates, String? routeId, LocationOption? originOption, LocationOption? destinationOption
});


@override $LocationOptionCopyWith<$Res>? get originOption;@override $LocationOptionCopyWith<$Res>? get destinationOption;

}
/// @nodoc
class __$MatrixRowCopyWithImpl<$Res>
    implements _$MatrixRowCopyWith<$Res> {
  __$MatrixRowCopyWithImpl(this._self, this._then);

  final _MatrixRow _self;
  final $Res Function(_MatrixRow) _then;

/// Create a copy of MatrixRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? origin = null,Object? destination = null,Object? rates = null,Object? routeId = freezed,Object? originOption = freezed,Object? destinationOption = freezed,}) {
  return _then(_MatrixRow(
origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,rates: null == rates ? _self._rates : rates // ignore: cast_nullable_to_non_nullable
as List<String>,routeId: freezed == routeId ? _self.routeId : routeId // ignore: cast_nullable_to_non_nullable
as String?,originOption: freezed == originOption ? _self.originOption : originOption // ignore: cast_nullable_to_non_nullable
as LocationOption?,destinationOption: freezed == destinationOption ? _self.destinationOption : destinationOption // ignore: cast_nullable_to_non_nullable
as LocationOption?,
  ));
}

/// Create a copy of MatrixRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationOptionCopyWith<$Res>? get originOption {
    if (_self.originOption == null) {
    return null;
  }

  return $LocationOptionCopyWith<$Res>(_self.originOption!, (value) {
    return _then(_self.copyWith(originOption: value));
  });
}/// Create a copy of MatrixRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationOptionCopyWith<$Res>? get destinationOption {
    if (_self.destinationOption == null) {
    return null;
  }

  return $LocationOptionCopyWith<$Res>(_self.destinationOption!, (value) {
    return _then(_self.copyWith(destinationOption: value));
  });
}
}

// dart format on
