import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/firebase_category_repository.dart';

part 'category_controller.g.dart';

@riverpod
class CategoryController extends _$CategoryController {
  @override
  FutureOr<void> build() {}

  Future<void> addCategory(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).addCategory(name);
    });
  }

  Future<void> deleteCategory(String categoryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).deleteCategory(categoryId);
    });
  }

  Future<void> addSubcategory(String categoryId, String subcategoryName) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).addSubcategory(categoryId, subcategoryName);
    });
  }

  Future<void> deleteSubcategory(String categoryId, String subcategoryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).deleteSubcategory(categoryId, subcategoryId);
    });
  }

  Future<void> addCategoryWithSubcategory(String categoryName, String? subcategoryName) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(categoryRepositoryProvider) as dynamic;
      await repo.addCategoryWithSubcategory(categoryName, subcategoryName);
    });
  }
}
