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
    // Dimension fields — 6 inputs, 3 rows
    String? height,       // Row-1 left  label "H"  (Height)
    String? length,       // Row-1 right label "L"  (Length)
    String? lengthB,      // Row-2 left  label "L"  (second Length / span)
    String? width,        // Row-2 right label "W"  (Width)
    String? itemHeight,   // Row-3 left  label "H"  (Height H)
    String? depth,        // Row-3 right label "D"  (Depth)
    /// Legacy — kept for records saved before dimension fields existed.
    String? size,
    String? additionalNotes,
  }) = _EventCategoryItem;

  factory EventCategoryItem.fromJson(Map<String, dynamic> json) => _$EventCategoryItemFromJson(json);
}
