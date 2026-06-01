import 'dart:io';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Stream<List<CategoryEntity>> watchCategories();
  Future<void> addCategory(String name);
  Future<void> deleteCategory(String categoryId);
  Future<void> addSubcategory(String categoryId, String subcategoryName, {File? imageFile});
  Future<void> deleteSubcategory(String categoryId, String subcategoryId);
  Future<void> addCategoryWithSubcategory(String categoryName, String? subcategoryName, {File? imageFile});
}
