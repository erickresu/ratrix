// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'addon_field_def.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddonFieldDef {

 String get key; String get label; bool get hasToggle;
/// Create a copy of AddonFieldDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddonFieldDefCopyWith<AddonFieldDef> get copyWith => _$AddonFieldDefCopyWithImpl<AddonFieldDef>(this as AddonFieldDef, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddonFieldDef&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.hasToggle, hasToggle) || other.hasToggle == hasToggle));
}


@override
int get hashCode => Object.hash(runtimeType,key,label,hasToggle);

@override
String toString() {
  return 'AddonFieldDef(key: $key, label: $label, hasToggle: $hasToggle)';
}


}

/// @nodoc
abstract mixin class $AddonFieldDefCopyWith<$Res>  {
  factory $AddonFieldDefCopyWith(AddonFieldDef value, $Res Function(AddonFieldDef) _then) = _$AddonFieldDefCopyWithImpl;
@useResult
$Res call({
 String key, String label, bool hasToggle
});




}
/// @nodoc
class _$AddonFieldDefCopyWithImpl<$Res>
    implements $AddonFieldDefCopyWith<$Res> {
  _$AddonFieldDefCopyWithImpl(this._self, this._then);

  final AddonFieldDef _self;
  final $Res Function(AddonFieldDef) _then;

/// Create a copy of AddonFieldDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? hasToggle = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,hasToggle: null == hasToggle ? _self.hasToggle : hasToggle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AddonFieldDef].
extension AddonFieldDefPatterns on AddonFieldDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddonFieldDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddonFieldDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddonFieldDef value)  $default,){
final _that = this;
switch (_that) {
case _AddonFieldDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddonFieldDef value)?  $default,){
final _that = this;
switch (_that) {
case _AddonFieldDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  bool hasToggle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddonFieldDef() when $default != null:
return $default(_that.key,_that.label,_that.hasToggle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  bool hasToggle)  $default,) {final _that = this;
switch (_that) {
case _AddonFieldDef():
return $default(_that.key,_that.label,_that.hasToggle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  bool hasToggle)?  $default,) {final _that = this;
switch (_that) {
case _AddonFieldDef() when $default != null:
return $default(_that.key,_that.label,_that.hasToggle);case _:
  return null;

}
}

}

/// @nodoc


class _AddonFieldDef implements AddonFieldDef {
  const _AddonFieldDef({required this.key, required this.label, this.hasToggle = false});
  

@override final  String key;
@override final  String label;
@override@JsonKey() final  bool hasToggle;

/// Create a copy of AddonFieldDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddonFieldDefCopyWith<_AddonFieldDef> get copyWith => __$AddonFieldDefCopyWithImpl<_AddonFieldDef>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddonFieldDef&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.hasToggle, hasToggle) || other.hasToggle == hasToggle));
}


@override
int get hashCode => Object.hash(runtimeType,key,label,hasToggle);

@override
String toString() {
  return 'AddonFieldDef(key: $key, label: $label, hasToggle: $hasToggle)';
}


}

/// @nodoc
abstract mixin class _$AddonFieldDefCopyWith<$Res> implements $AddonFieldDefCopyWith<$Res> {
  factory _$AddonFieldDefCopyWith(_AddonFieldDef value, $Res Function(_AddonFieldDef) _then) = __$AddonFieldDefCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, bool hasToggle
});




}
/// @nodoc
class __$AddonFieldDefCopyWithImpl<$Res>
    implements _$AddonFieldDefCopyWith<$Res> {
  __$AddonFieldDefCopyWithImpl(this._self, this._then);

  final _AddonFieldDef _self;
  final $Res Function(_AddonFieldDef) _then;

/// Create a copy of AddonFieldDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? hasToggle = null,}) {
  return _then(_AddonFieldDef(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,hasToggle: null == hasToggle ? _self.hasToggle : hasToggle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$AddonGroupDef {

 String get title; List<AddonFieldDef> get fields;
/// Create a copy of AddonGroupDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddonGroupDefCopyWith<AddonGroupDef> get copyWith => _$AddonGroupDefCopyWithImpl<AddonGroupDef>(this as AddonGroupDef, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddonGroupDef&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.fields, fields));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(fields));

@override
String toString() {
  return 'AddonGroupDef(title: $title, fields: $fields)';
}


}

/// @nodoc
abstract mixin class $AddonGroupDefCopyWith<$Res>  {
  factory $AddonGroupDefCopyWith(AddonGroupDef value, $Res Function(AddonGroupDef) _then) = _$AddonGroupDefCopyWithImpl;
@useResult
$Res call({
 String title, List<AddonFieldDef> fields
});




}
/// @nodoc
class _$AddonGroupDefCopyWithImpl<$Res>
    implements $AddonGroupDefCopyWith<$Res> {
  _$AddonGroupDefCopyWithImpl(this._self, this._then);

  final AddonGroupDef _self;
  final $Res Function(AddonGroupDef) _then;

/// Create a copy of AddonGroupDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? fields = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<AddonFieldDef>,
  ));
}

}


/// Adds pattern-matching-related methods to [AddonGroupDef].
extension AddonGroupDefPatterns on AddonGroupDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddonGroupDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddonGroupDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddonGroupDef value)  $default,){
final _that = this;
switch (_that) {
case _AddonGroupDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddonGroupDef value)?  $default,){
final _that = this;
switch (_that) {
case _AddonGroupDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  List<AddonFieldDef> fields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddonGroupDef() when $default != null:
return $default(_that.title,_that.fields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  List<AddonFieldDef> fields)  $default,) {final _that = this;
switch (_that) {
case _AddonGroupDef():
return $default(_that.title,_that.fields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  List<AddonFieldDef> fields)?  $default,) {final _that = this;
switch (_that) {
case _AddonGroupDef() when $default != null:
return $default(_that.title,_that.fields);case _:
  return null;

}
}

}

/// @nodoc


class _AddonGroupDef implements AddonGroupDef {
  const _AddonGroupDef({required this.title, required final  List<AddonFieldDef> fields}): _fields = fields;
  

@override final  String title;
 final  List<AddonFieldDef> _fields;
@override List<AddonFieldDef> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}


/// Create a copy of AddonGroupDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddonGroupDefCopyWith<_AddonGroupDef> get copyWith => __$AddonGroupDefCopyWithImpl<_AddonGroupDef>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddonGroupDef&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._fields, _fields));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_fields));

@override
String toString() {
  return 'AddonGroupDef(title: $title, fields: $fields)';
}


}

/// @nodoc
abstract mixin class _$AddonGroupDefCopyWith<$Res> implements $AddonGroupDefCopyWith<$Res> {
  factory _$AddonGroupDefCopyWith(_AddonGroupDef value, $Res Function(_AddonGroupDef) _then) = __$AddonGroupDefCopyWithImpl;
@override @useResult
$Res call({
 String title, List<AddonFieldDef> fields
});




}
/// @nodoc
class __$AddonGroupDefCopyWithImpl<$Res>
    implements _$AddonGroupDefCopyWith<$Res> {
  __$AddonGroupDefCopyWithImpl(this._self, this._then);

  final _AddonGroupDef _self;
  final $Res Function(_AddonGroupDef) _then;

/// Create a copy of AddonGroupDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? fields = null,}) {
  return _then(_AddonGroupDef(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<AddonFieldDef>,
  ));
}


}

// dart format on
