import 'package:freezed_annotation/freezed_annotation.dart';
import 'event_category_item.dart';

part 'event_entity.freezed.dart';
part 'event_entity.g.dart';

@freezed
abstract class EventEntity with _$EventEntity {
  const factory EventEntity({
    required String id,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required String address,
    required String creatorId,
    @Default([]) List<EventCategoryItem> items,
    @Default(false) bool isCompleted,
  }) = _EventEntity;

  factory EventEntity.fromJson(Map<String, dynamic> json) => _$EventEntityFromJson(json);
}
