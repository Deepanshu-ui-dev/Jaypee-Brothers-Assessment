import '../local/hive_service.dart';
import '../models/category_model.dart';

class CategoryRepository {
  List<CategoryModel> getAll() {
    final box = HiveService.categories;
    if (box.isEmpty) {
      _seedDefaults();
    }
    return box.values.toList();
  }

  void _seedDefaults() {
    final box = HiveService.categories;
    for (final cat in kAllDefaultCategories) {
      box.put(cat.id, cat);
    }
  }

  Future<void> seedDefaultsIfNeeded() async {
    final box = HiveService.categories;
    if (box.isEmpty) {
      for (final cat in kAllDefaultCategories) {
        await box.put(cat.id, cat);
      }
    }
  }

  Future<void> add(CategoryModel category) async {
    await HiveService.categories.put(category.id, category);
  }

  Future<void> delete(String categoryId) async {
    final cat = HiveService.categories.get(categoryId);
    if (cat == null) return;
    if (cat.isDefault) {
      throw Exception('Cannot delete a default category.');
    }
    await HiveService.categories.delete(categoryId);
  }
}
