// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subcategory_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubcategoryEntity _$SubcategoryEntityFromJson(Map<String, dynamic> json) =>
    _SubcategoryEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$SubcategoryEntityToJson(_SubcategoryEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
    };
