// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventEntity _$EventEntityFromJson(Map<String, dynamic> json) => _EventEntity(
  id: json['id'] as String,
  name: json['name'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  address: json['address'] as String,
  creatorId: json['creatorId'] as String,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => EventCategoryItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isCompleted: json['isCompleted'] as bool? ?? false,
);

Map<String, dynamic> _$EventEntityToJson(_EventEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'address': instance.address,
      'creatorId': instance.creatorId,
      'items': instance.items,
      'isCompleted': instance.isCompleted,
    };
