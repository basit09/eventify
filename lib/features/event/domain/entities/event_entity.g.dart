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
  setupDate: DateTime.parse(json['setupDate'] as String),
  contactPerson: json['contactPerson'] as String?,
  contactPhone: json['contactPhone'] as String?,
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
      'setupDate': instance.setupDate.toIso8601String(),
      'contactPerson': instance.contactPerson,
      'contactPhone': instance.contactPhone,
      'items': instance.items,
      'isCompleted': instance.isCompleted,
    };
