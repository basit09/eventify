import 'package:freezed_annotation/freezed_annotation.dart';

part 'subcategory_entity.freezed.dart';
part 'subcategory_entity.g.dart';

@freezed
abstract class SubcategoryEntity with _$SubcategoryEntity {
  const factory SubcategoryEntity({
    required String id,
    required String name,
  }) = _SubcategoryEntity;

  factory SubcategoryEntity.fromJson(Map<String, dynamic> json) => _$SubcategoryEntityFromJson(json);
}
