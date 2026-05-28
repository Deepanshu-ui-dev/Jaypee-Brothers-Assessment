import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('categories');

  /// Real-time stream of all user categories
  Stream<List<CategoryModel>> watchAll(String uid) {
    return _col(uid).snapshots().map(
          (snap) => snap.docs.map(CategoryModel.fromFirestore).toList(),
        );
  }

  /// Seeds default categories if none exist yet
  Future<void> seedDefaultsIfNeeded(String uid) async {
    final snap = await _col(uid).limit(1).get();
    if (snap.docs.isEmpty) {
      final batch = _firestore.batch();
      for (final cat in kAllDefaultCategories) {
        final docRef = _col(uid).doc(cat.id);
        batch.set(docRef, cat.toFirestore());
      }
      await batch.commit();
    }
  }

  /// Add a custom category
  Future<void> add(String uid, CategoryModel category) async {
    await _col(uid).doc(category.id).set(category.toFirestore());
  }

  /// Delete a custom category (guards against deleting defaults)
  Future<void> delete(String uid, String categoryId) async {
    final doc = await _col(uid).doc(categoryId).get();
    if (doc.exists) {
      final data = doc.data()!;
      if (data['isDefault'] == true) {
        throw Exception('Cannot delete a default category.');
      }
      await _col(uid).doc(categoryId).delete();
    }
  }
}
