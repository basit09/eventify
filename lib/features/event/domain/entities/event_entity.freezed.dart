// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventEntity {

 String get id; String get name; DateTime get startDate; DateTime get endDate; String get address; String get creatorId; String get setupDate; String? get contactPerson; String? get contactPhone; List<EventCategoryItem> get items; bool get isCompleted;
/// Create a copy of EventEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventEntityCopyWith<EventEntity> get copyWith => _$EventEntityCopyWithImpl<EventEntity>(this as EventEntity, _$identity);

  /// Serializes this EventEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.address, address) || other.address == address)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.setupDate, setupDate) || other.setupDate == setupDate)&&(identical(other.contactPerson, contactPerson) || other.contactPerson == contactPerson)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,startDate,endDate,address,creatorId,setupDate,contactPerson,contactPhone,const DeepCollectionEquality().hash(items),isCompleted);

@override
String toString() {
  return 'EventEntity(id: $id, name: $name, startDate: $startDate, endDate: $endDate, address: $address, creatorId: $creatorId, setupDate: $setupDate, contactPerson: $contactPerson, contactPhone: $contactPhone, items: $items, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class $EventEntityCopyWith<$Res>  {
  factory $EventEntityCopyWith(EventEntity value, $Res Function(EventEntity) _then) = _$EventEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime startDate, DateTime endDate, String address, String creatorId, String setupDate, String? contactPerson, String? contactPhone, List<EventCategoryItem> items, bool isCompleted
});




}
/// @nodoc
class _$EventEntityCopyWithImpl<$Res>
    implements $EventEntityCopyWith<$Res> {
  _$EventEntityCopyWithImpl(this._self, this._then);

  final EventEntity _self;
  final $Res Function(EventEntity) _then;

/// Create a copy of EventEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? startDate = null,Object? endDate = null,Object? address = null,Object? creatorId = null,Object? setupDate = null,Object? contactPerson = freezed,Object? contactPhone = freezed,Object? items = null,Object? isCompleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,setupDate: null == setupDate ? _self.setupDate : setupDate // ignore: cast_nullable_to_non_nullable
as String,contactPerson: freezed == contactPerson ? _self.contactPerson : contactPerson // ignore: cast_nullable_to_non_nullable
as String?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<EventCategoryItem>,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EventEntity].
extension EventEntityPatterns on EventEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventEntity value)  $default,){
final _that = this;
switch (_that) {
case _EventEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventEntity value)?  $default,){
final _that = this;
switch (_that) {
case _EventEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime startDate,  DateTime endDate,  String address,  String creatorId,  String setupDate,  String? contactPerson,  String? contactPhone,  List<EventCategoryItem> items,  bool isCompleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventEntity() when $default != null:
return $default(_that.id,_that.name,_that.startDate,_that.endDate,_that.address,_that.creatorId,_that.setupDate,_that.contactPerson,_that.contactPhone,_that.items,_that.isCompleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime startDate,  DateTime endDate,  String address,  String creatorId,  String setupDate,  String? contactPerson,  String? contactPhone,  List<EventCategoryItem> items,  bool isCompleted)  $default,) {final _that = this;
switch (_that) {
case _EventEntity():
return $default(_that.id,_that.name,_that.startDate,_that.endDate,_that.address,_that.creatorId,_that.setupDate,_that.contactPerson,_that.contactPhone,_that.items,_that.isCompleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime startDate,  DateTime endDate,  String address,  String creatorId,  String setupDate,  String? contactPerson,  String? contactPhone,  List<EventCategoryItem> items,  bool isCompleted)?  $default,) {final _that = this;
switch (_that) {
case _EventEntity() when $default != null:
return $default(_that.id,_that.name,_that.startDate,_that.endDate,_that.address,_that.creatorId,_that.setupDate,_that.contactPerson,_that.contactPhone,_that.items,_that.isCompleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventEntity implements EventEntity {
  const _EventEntity({required this.id, required this.name, required this.startDate, required this.endDate, required this.address, required this.creatorId, required this.setupDate, this.contactPerson, this.contactPhone, final  List<EventCategoryItem> items = const [], this.isCompleted = false}): _items = items;
  factory _EventEntity.fromJson(Map<String, dynamic> json) => _$EventEntityFromJson(json);

@override final  String id;
@override final  String name;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override final  String address;
@override final  String creatorId;
@override final  String setupDate;
@override final  String? contactPerson;
@override final  String? contactPhone;
 final  List<EventCategoryItem> _items;
@override@JsonKey() List<EventCategoryItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool isCompleted;

/// Create a copy of EventEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventEntityCopyWith<_EventEntity> get copyWith => __$EventEntityCopyWithImpl<_EventEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.address, address) || other.address == address)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.setupDate, setupDate) || other.setupDate == setupDate)&&(identical(other.contactPerson, contactPerson) || other.contactPerson == contactPerson)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,startDate,endDate,address,creatorId,setupDate,contactPerson,contactPhone,const DeepCollectionEquality().hash(_items),isCompleted);

@override
String toString() {
  return 'EventEntity(id: $id, name: $name, startDate: $startDate, endDate: $endDate, address: $address, creatorId: $creatorId, setupDate: $setupDate, contactPerson: $contactPerson, contactPhone: $contactPhone, items: $items, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class _$EventEntityCopyWith<$Res> implements $EventEntityCopyWith<$Res> {
  factory _$EventEntityCopyWith(_EventEntity value, $Res Function(_EventEntity) _then) = __$EventEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime startDate, DateTime endDate, String address, String creatorId, String setupDate, String? contactPerson, String? contactPhone, List<EventCategoryItem> items, bool isCompleted
});




}
/// @nodoc
class __$EventEntityCopyWithImpl<$Res>
    implements _$EventEntityCopyWith<$Res> {
  __$EventEntityCopyWithImpl(this._self, this._then);

  final _EventEntity _self;
  final $Res Function(_EventEntity) _then;

/// Create a copy of EventEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? startDate = null,Object? endDate = null,Object? address = null,Object? creatorId = null,Object? setupDate = null,Object? contactPerson = freezed,Object? contactPhone = freezed,Object? items = null,Object? isCompleted = null,}) {
  return _then(_EventEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,setupDate: null == setupDate ? _self.setupDate : setupDate // ignore: cast_nullable_to_non_nullable
as String,contactPerson: freezed == contactPerson ? _self.contactPerson : contactPerson // ignore: cast_nullable_to_non_nullable
as String?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<EventCategoryItem>,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
