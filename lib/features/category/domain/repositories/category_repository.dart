import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Stream<List<CategoryEntity>> watchCategories();
  Future<void> addCategory(String name);
  Future<void> deleteCategory(String categoryId);
  Future<void> addSubcategory(String categoryId, String subcategoryName);
  Future<void> deleteSubcategory(String categoryId, String subcategoryId);
}
