import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../../domain/repositories/category_repository.dart';

part 'firebase_category_repository.g.dart';

class FirebaseCategoryRepository implements CategoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseCategoryRepository(this._firestore, this._storage);

  CollectionReference get _categoriesCollection => _firestore.collection('categories');

  @override
  Stream<List<CategoryEntity>> watchCategories() {
    return _categoriesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // ensure ID is passed via JSON if not stored
        return CategoryEntity.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<void> addCategory(String name) async {
    final newDoc = _categoriesCollection.doc();
    final category = CategoryEntity(id: newDoc.id, name: name);
    await newDoc.set(category.toJson());
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _categoriesCollection.doc(categoryId).delete();
  }

  @override
  Future<void> addSubcategory(String categoryId, String subcategoryName, {File? imageFile}) async {
    final docRef = _categoriesCollection.doc(categoryId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) return;

    final data = docSnap.data() as Map<String, dynamic>;
    data['id'] = docSnap.id;
    final category = CategoryEntity.fromJson(data);

    final subId = docRef.collection('subcategories').doc().id;
    String? imageUrl;

    if (imageFile != null) {
      final storageRef = _storage.ref().child('subcategories').child('$subId.jpg');
      await storageRef.putFile(imageFile);
      imageUrl = await storageRef.getDownloadURL();
    }

    final newSub = SubcategoryEntity(
      id: subId,
      name: subcategoryName,
      imageUrl: imageUrl,
    );

    final updatedSubs = List<SubcategoryEntity>.from(category.subcategories)..add(newSub);
    final updatedCategory = category.copyWith(subcategories: updatedSubs);

    await docRef.update({'subcategories': updatedCategory.subcategories.map((e) => e.toJson()).toList()});
  }

  @override
  Future<void> deleteSubcategory(String categoryId, String subcategoryId) async {
    final docRef = _categoriesCollection.doc(categoryId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) return;

    final data = docSnap.data() as Map<String, dynamic>;
    data['id'] = docSnap.id;
    final category = CategoryEntity.fromJson(data);

    final updatedSubs = category.subcategories.where((sub) => sub.id != subcategoryId).toList();
    final updatedCategory = category.copyWith(subcategories: updatedSubs);

    await docRef.update({'subcategories': updatedCategory.subcategories.map((e) => e.toJson()).toList()});
  }

  /// Creates a new category and optionally attaches a first subcategory.
  @override
  Future<void> addCategoryWithSubcategory(String categoryName, String? subcategoryName, {File? imageFile}) async {
    final newDoc = _categoriesCollection.doc();
    final subs = <SubcategoryEntity>[];
    if (subcategoryName != null && subcategoryName.trim().isNotEmpty) {
      final subId = newDoc.collection('subs').doc().id;
      String? imageUrl;

      if (imageFile != null) {
        final storageRef = _storage.ref().child('subcategories').child('$subId.jpg');
        await storageRef.putFile(imageFile);
        imageUrl = await storageRef.getDownloadURL();
      }

      subs.add(SubcategoryEntity(
        id: subId,
        name: subcategoryName.trim(),
        imageUrl: imageUrl,
      ));
    }
    final category = CategoryEntity(
      id: newDoc.id,
      name: categoryName.trim(),
      subcategories: subs,
    );
    // Serialize subcategories explicitly
    final json = category.toJson();
    json['subcategories'] = subs.map((e) => e.toJson()).toList();
    await newDoc.set(json);
  }
}

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@Riverpod(keepAlive: true)
FirebaseStorage firebaseStorage(Ref ref) {
  return FirebaseStorage.instance;
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  return FirebaseCategoryRepository(
    ref.watch(firebaseFirestoreProvider),
    ref.watch(firebaseStorageProvider),
  );
}

@Riverpod(keepAlive: true)
Stream<List<CategoryEntity>> categoriesStream(Ref ref) {
  return ref.watch(categoryRepositoryProvider).watchCategories();
}
