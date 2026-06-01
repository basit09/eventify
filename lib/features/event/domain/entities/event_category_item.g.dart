// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_category_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventCategoryItem _$EventCategoryItemFromJson(Map<String, dynamic> json) =>
    _EventCategoryItem(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      subcategoryId: json['subcategoryId'] as String,
      subcategoryName: json['subcategoryName'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      height: json['height'] as String?,
      length: json['length'] as String?,
      lengthB: json['lengthB'] as String?,
      width: json['width'] as String?,
      itemHeight: json['itemHeight'] as String?,
      depth: json['depth'] as String?,
      size: json['size'] as String?,
      additionalNotes: json['additionalNotes'] as String?,
    );

Map<String, dynamic> _$EventCategoryItemToJson(_EventCategoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'subcategoryId': instance.subcategoryId,
      'subcategoryName': instance.subcategoryName,
      'quantity': instance.quantity,
      'height': instance.height,
      'length': instance.length,
      'lengthB': instance.lengthB,
      'width': instance.width,
      'itemHeight': instance.itemHeight,
      'depth': instance.depth,
      'size': instance.size,
      'additionalNotes': instance.additionalNotes,
    };
