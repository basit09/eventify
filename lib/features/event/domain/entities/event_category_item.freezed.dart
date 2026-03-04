// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_category_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventCategoryItem {

 String get id; String get categoryId; String get categoryName; String get subcategoryId; String get subcategoryName; int get quantity; String? get size;// e.g. "10x10"
 String? get additionalNotes;
/// Create a copy of EventCategoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCategoryItemCopyWith<EventCategoryItem> get copyWith => _$EventCategoryItemCopyWithImpl<EventCategoryItem>(this as EventCategoryItem, _$identity);

  /// Serializes this EventCategoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventCategoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.subcategoryId, subcategoryId) || other.subcategoryId == subcategoryId)&&(identical(other.subcategoryName, subcategoryName) || other.subcategoryName == subcategoryName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.size, size) || other.size == size)&&(identical(other.additionalNotes, additionalNotes) || other.additionalNotes == additionalNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,categoryName,subcategoryId,subcategoryName,quantity,size,additionalNotes);

@override
String toString() {
  return 'EventCategoryItem(id: $id, categoryId: $categoryId, categoryName: $categoryName, subcategoryId: $subcategoryId, subcategoryName: $subcategoryName, quantity: $quantity, size: $size, additionalNotes: $additionalNotes)';
}


}

/// @nodoc
abstract mixin class $EventCategoryItemCopyWith<$Res>  {
  factory $EventCategoryItemCopyWith(EventCategoryItem value, $Res Function(EventCategoryItem) _then) = _$EventCategoryItemCopyWithImpl;
@useResult
$Res call({
 String id, String categoryId, String categoryName, String subcategoryId, String subcategoryName, int quantity, String? size, String? additionalNotes
});




}
/// @nodoc
class _$EventCategoryItemCopyWithImpl<$Res>
    implements $EventCategoryItemCopyWith<$Res> {
  _$EventCategoryItemCopyWithImpl(this._self, this._then);

  final EventCategoryItem _self;
  final $Res Function(EventCategoryItem) _then;

/// Create a copy of EventCategoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoryId = null,Object? categoryName = null,Object? subcategoryId = null,Object? subcategoryName = null,Object? quantity = null,Object? size = freezed,Object? additionalNotes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,subcategoryId: null == subcategoryId ? _self.subcategoryId : subcategoryId // ignore: cast_nullable_to_non_nullable
as String,subcategoryName: null == subcategoryName ? _self.subcategoryName : subcategoryName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,additionalNotes: freezed == additionalNotes ? _self.additionalNotes : additionalNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventCategoryItem].
extension EventCategoryItemPatterns on EventCategoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventCategoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventCategoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventCategoryItem value)  $default,){
final _that = this;
switch (_that) {
case _EventCategoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventCategoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _EventCategoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String categoryId,  String categoryName,  String subcategoryId,  String subcategoryName,  int quantity,  String? size,  String? additionalNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventCategoryItem() when $default != null:
return $default(_that.id,_that.categoryId,_that.categoryName,_that.subcategoryId,_that.subcategoryName,_that.quantity,_that.size,_that.additionalNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String categoryId,  String categoryName,  String subcategoryId,  String subcategoryName,  int quantity,  String? size,  String? additionalNotes)  $default,) {final _that = this;
switch (_that) {
case _EventCategoryItem():
return $default(_that.id,_that.categoryId,_that.categoryName,_that.subcategoryId,_that.subcategoryName,_that.quantity,_that.size,_that.additionalNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String categoryId,  String categoryName,  String subcategoryId,  String subcategoryName,  int quantity,  String? size,  String? additionalNotes)?  $default,) {final _that = this;
switch (_that) {
case _EventCategoryItem() when $default != null:
return $default(_that.id,_that.categoryId,_that.categoryName,_that.subcategoryId,_that.subcategoryName,_that.quantity,_that.size,_that.additionalNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventCategoryItem implements EventCategoryItem {
  const _EventCategoryItem({required this.id, required this.categoryId, required this.categoryName, required this.subcategoryId, required this.subcategoryName, this.quantity = 1, this.size, this.additionalNotes});
  factory _EventCategoryItem.fromJson(Map<String, dynamic> json) => _$EventCategoryItemFromJson(json);

@override final  String id;
@override final  String categoryId;
@override final  String categoryName;
@override final  String subcategoryId;
@override final  String subcategoryName;
@override@JsonKey() final  int quantity;
@override final  String? size;
// e.g. "10x10"
@override final  String? additionalNotes;

/// Create a copy of EventCategoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCategoryItemCopyWith<_EventCategoryItem> get copyWith => __$EventCategoryItemCopyWithImpl<_EventCategoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventCategoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventCategoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.subcategoryId, subcategoryId) || other.subcategoryId == subcategoryId)&&(identical(other.subcategoryName, subcategoryName) || other.subcategoryName == subcategoryName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.size, size) || other.size == size)&&(identical(other.additionalNotes, additionalNotes) || other.additionalNotes == additionalNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,categoryName,subcategoryId,subcategoryName,quantity,size,additionalNotes);

@override
String toString() {
  return 'EventCategoryItem(id: $id, categoryId: $categoryId, categoryName: $categoryName, subcategoryId: $subcategoryId, subcategoryName: $subcategoryName, quantity: $quantity, size: $size, additionalNotes: $additionalNotes)';
}


}

/// @nodoc
abstract mixin class _$EventCategoryItemCopyWith<$Res> implements $EventCategoryItemCopyWith<$Res> {
  factory _$EventCategoryItemCopyWith(_EventCategoryItem value, $Res Function(_EventCategoryItem) _then) = __$EventCategoryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String categoryId, String categoryName, String subcategoryId, String subcategoryName, int quantity, String? size, String? additionalNotes
});




}
/// @nodoc
class __$EventCategoryItemCopyWithImpl<$Res>
    implements _$EventCategoryItemCopyWith<$Res> {
  __$EventCategoryItemCopyWithImpl(this._self, this._then);

  final _EventCategoryItem _self;
  final $Res Function(_EventCategoryItem) _then;

/// Create a copy of EventCategoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoryId = null,Object? categoryName = null,Object? subcategoryId = null,Object? subcategoryName = null,Object? quantity = null,Object? size = freezed,Object? additionalNotes = freezed,}) {
  return _then(_EventCategoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,subcategoryId: null == subcategoryId ? _self.subcategoryId : subcategoryId // ignore: cast_nullable_to_non_nullable
as String,subcategoryName: null == subcategoryName ? _self.subcategoryName : subcategoryName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,additionalNotes: freezed == additionalNotes ? _self.additionalNotes : additionalNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
