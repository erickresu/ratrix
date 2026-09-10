// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rate_import_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RateImportData {

 FreightMode get freightMode; ServiceMode get serviceMode; ChargeBasis get chargeBasis; PricingOption get pricingOption; List<Breakweight> get breakweights; List<MatrixRow> get matrixRows; List<String> get skippedRows;
/// Create a copy of RateImportData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RateImportDataCopyWith<RateImportData> get copyWith => _$RateImportDataCopyWithImpl<RateImportData>(this as RateImportData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RateImportData&&(identical(other.freightMode, freightMode) || other.freightMode == freightMode)&&(identical(other.serviceMode, serviceMode) || other.serviceMode == serviceMode)&&(identical(other.chargeBasis, chargeBasis) || other.chargeBasis == chargeBasis)&&(identical(other.pricingOption, pricingOption) || other.pricingOption == pricingOption)&&const DeepCollectionEquality().equals(other.breakweights, breakweights)&&const DeepCollectionEquality().equals(other.matrixRows, matrixRows)&&const DeepCollectionEquality().equals(other.skippedRows, skippedRows));
}


@override
int get hashCode => Object.hash(runtimeType,freightMode,serviceMode,chargeBasis,pricingOption,const DeepCollectionEquality().hash(breakweights),const DeepCollectionEquality().hash(matrixRows),const DeepCollectionEquality().hash(skippedRows));

@override
String toString() {
  return 'RateImportData(freightMode: $freightMode, serviceMode: $serviceMode, chargeBasis: $chargeBasis, pricingOption: $pricingOption, breakweights: $breakweights, matrixRows: $matrixRows, skippedRows: $skippedRows)';
}


}

/// @nodoc
abstract mixin class $RateImportDataCopyWith<$Res>  {
  factory $RateImportDataCopyWith(RateImportData value, $Res Function(RateImportData) _then) = _$RateImportDataCopyWithImpl;
@useResult
$Res call({
 FreightMode freightMode, ServiceMode serviceMode, ChargeBasis chargeBasis, PricingOption pricingOption, List<Breakweight> breakweights, List<MatrixRow> matrixRows, List<String> skippedRows
});




}
/// @nodoc
class _$RateImportDataCopyWithImpl<$Res>
    implements $RateImportDataCopyWith<$Res> {
  _$RateImportDataCopyWithImpl(this._self, this._then);

  final RateImportData _self;
  final $Res Function(RateImportData) _then;

/// Create a copy of RateImportData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? freightMode = null,Object? serviceMode = null,Object? chargeBasis = null,Object? pricingOption = null,Object? breakweights = null,Object? matrixRows = null,Object? skippedRows = null,}) {
  return _then(_self.copyWith(
freightMode: null == freightMode ? _self.freightMode : freightMode // ignore: cast_nullable_to_non_nullable
as FreightMode,serviceMode: null == serviceMode ? _self.serviceMode : serviceMode // ignore: cast_nullable_to_non_nullable
as ServiceMode,chargeBasis: null == chargeBasis ? _self.chargeBasis : chargeBasis // ignore: cast_nullable_to_non_nullable
as ChargeBasis,pricingOption: null == pricingOption ? _self.pricingOption : pricingOption // ignore: cast_nullable_to_non_nullable
as PricingOption,breakweights: null == breakweights ? _self.breakweights : breakweights // ignore: cast_nullable_to_non_nullable
as List<Breakweight>,matrixRows: null == matrixRows ? _self.matrixRows : matrixRows // ignore: cast_nullable_to_non_nullable
as List<MatrixRow>,skippedRows: null == skippedRows ? _self.skippedRows : skippedRows // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RateImportData].
extension RateImportDataPatterns on RateImportData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RateImportData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RateImportData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RateImportData value)  $default,){
final _that = this;
switch (_that) {
case _RateImportData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RateImportData value)?  $default,){
final _that = this;
switch (_that) {
case _RateImportData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FreightMode freightMode,  ServiceMode serviceMode,  ChargeBasis chargeBasis,  PricingOption pricingOption,  List<Breakweight> breakweights,  List<MatrixRow> matrixRows,  List<String> skippedRows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RateImportData() when $default != null:
return $default(_that.freightMode,_that.serviceMode,_that.chargeBasis,_that.pricingOption,_that.breakweights,_that.matrixRows,_that.skippedRows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FreightMode freightMode,  ServiceMode serviceMode,  ChargeBasis chargeBasis,  PricingOption pricingOption,  List<Breakweight> breakweights,  List<MatrixRow> matrixRows,  List<String> skippedRows)  $default,) {final _that = this;
switch (_that) {
case _RateImportData():
return $default(_that.freightMode,_that.serviceMode,_that.chargeBasis,_that.pricingOption,_that.breakweights,_that.matrixRows,_that.skippedRows);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FreightMode freightMode,  ServiceMode serviceMode,  ChargeBasis chargeBasis,  PricingOption pricingOption,  List<Breakweight> breakweights,  List<MatrixRow> matrixRows,  List<String> skippedRows)?  $default,) {final _that = this;
switch (_that) {
case _RateImportData() when $default != null:
return $default(_that.freightMode,_that.serviceMode,_that.chargeBasis,_that.pricingOption,_that.breakweights,_that.matrixRows,_that.skippedRows);case _:
  return null;

}
}

}

/// @nodoc


class _RateImportData implements RateImportData {
  const _RateImportData({required this.freightMode, required this.serviceMode, required this.chargeBasis, required this.pricingOption, required final  List<Breakweight> breakweights, required final  List<MatrixRow> matrixRows, final  List<String> skippedRows = const []}): _breakweights = breakweights,_matrixRows = matrixRows,_skippedRows = skippedRows;
  

@override final  FreightMode freightMode;
@override final  ServiceMode serviceMode;
@override final  ChargeBasis chargeBasis;
@override final  PricingOption pricingOption;
 final  List<Breakweight> _breakweights;
@override List<Breakweight> get breakweights {
  if (_breakweights is EqualUnmodifiableListView) return _breakweights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_breakweights);
}

 final  List<MatrixRow> _matrixRows;
@override List<MatrixRow> get matrixRows {
  if (_matrixRows is EqualUnmodifiableListView) return _matrixRows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_matrixRows);
}

 final  List<String> _skippedRows;
@override@JsonKey() List<String> get skippedRows {
  if (_skippedRows is EqualUnmodifiableListView) return _skippedRows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skippedRows);
}


/// Create a copy of RateImportData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RateImportDataCopyWith<_RateImportData> get copyWith => __$RateImportDataCopyWithImpl<_RateImportData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RateImportData&&(identical(other.freightMode, freightMode) || other.freightMode == freightMode)&&(identical(other.serviceMode, serviceMode) || other.serviceMode == serviceMode)&&(identical(other.chargeBasis, chargeBasis) || other.chargeBasis == chargeBasis)&&(identical(other.pricingOption, pricingOption) || other.pricingOption == pricingOption)&&const DeepCollectionEquality().equals(other._breakweights, _breakweights)&&const DeepCollectionEquality().equals(other._matrixRows, _matrixRows)&&const DeepCollectionEquality().equals(other._skippedRows, _skippedRows));
}


@override
int get hashCode => Object.hash(runtimeType,freightMode,serviceMode,chargeBasis,pricingOption,const DeepCollectionEquality().hash(_breakweights),const DeepCollectionEquality().hash(_matrixRows),const DeepCollectionEquality().hash(_skippedRows));

@override
String toString() {
  return 'RateImportData(freightMode: $freightMode, serviceMode: $serviceMode, chargeBasis: $chargeBasis, pricingOption: $pricingOption, breakweights: $breakweights, matrixRows: $matrixRows, skippedRows: $skippedRows)';
}


}

/// @nodoc
abstract mixin class _$RateImportDataCopyWith<$Res> implements $RateImportDataCopyWith<$Res> {
  factory _$RateImportDataCopyWith(_RateImportData value, $Res Function(_RateImportData) _then) = __$RateImportDataCopyWithImpl;
@override @useResult
$Res call({
 FreightMode freightMode, ServiceMode serviceMode, ChargeBasis chargeBasis, PricingOption pricingOption, List<Breakweight> breakweights, List<MatrixRow> matrixRows, List<String> skippedRows
});




}
/// @nodoc
class __$RateImportDataCopyWithImpl<$Res>
    implements _$RateImportDataCopyWith<$Res> {
  __$RateImportDataCopyWithImpl(this._self, this._then);

  final _RateImportData _self;
  final $Res Function(_RateImportData) _then;

/// Create a copy of RateImportData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? freightMode = null,Object? serviceMode = null,Object? chargeBasis = null,Object? pricingOption = null,Object? breakweights = null,Object? matrixRows = null,Object? skippedRows = null,}) {
  return _then(_RateImportData(
freightMode: null == freightMode ? _self.freightMode : freightMode // ignore: cast_nullable_to_non_nullable
as FreightMode,serviceMode: null == serviceMode ? _self.serviceMode : serviceMode // ignore: cast_nullable_to_non_nullable
as ServiceMode,chargeBasis: null == chargeBasis ? _self.chargeBasis : chargeBasis // ignore: cast_nullable_to_non_nullable
as ChargeBasis,pricingOption: null == pricingOption ? _self.pricingOption : pricingOption // ignore: cast_nullable_to_non_nullable
as PricingOption,breakweights: null == breakweights ? _self._breakweights : breakweights // ignore: cast_nullable_to_non_nullable
as List<Breakweight>,matrixRows: null == matrixRows ? _self._matrixRows : matrixRows // ignore: cast_nullable_to_non_nullable
as List<MatrixRow>,skippedRows: null == skippedRows ? _self._skippedRows : skippedRows // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
