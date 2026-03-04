import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_category_item.freezed.dart';
part 'event_category_item.g.dart';

@freezed
abstract class EventCategoryItem with _$EventCategoryItem {
  const factory EventCategoryItem({
    required String id,
    required String categoryId,
    required String categoryName,
    required String subcategoryId,
    required String subcategoryName,
    @Default(1) int quantity,
    String? size, // e.g. "10x10"
    String? additionalNotes, // soft field
  }) = _EventCategoryItem;

  factory EventCategoryItem.fromJson(Map<String, dynamic> json) => _$EventCategoryItemFromJson(json);
}
