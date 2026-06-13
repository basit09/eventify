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
    // ── 4 dimension fields ──────────────────────────────────────────────────
    String? length,   // Row-1 left   (Length × Width)
    String? width,    // Row-1 right
    String? height,   // Row-2 left   (Height   Depth — no × sign)
    String? depth,    // Row-2 right
    String? additionalNotes,
  }) = _EventCategoryItem;

  factory EventCategoryItem.fromJson(Map<String, dynamic> json) =>
      _$EventCategoryItemFromJson(json);
}
