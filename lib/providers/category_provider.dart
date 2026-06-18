import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/category_model.dart';
import '../data/repositories/category_repository.dart';

// ── Repository ────────────────────────────────────────────────────────────
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

// ── All Categories (seeded from Hive) ────────────────────────────────────
final categoriesProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return CategoryNotifier(repo);
});

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  CategoryNotifier(this._repo) : super([]) {
    _load();
  }

  final CategoryRepository _repo;

  Future<void> _load() async {
    await _repo.seedDefaultsIfNeeded();
    state = _repo.getAll();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _repo.add(category);
    state = _repo.getAll();
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repo.delete(categoryId);
    state = _repo.getAll();
  }

  void reload() => state = _repo.getAll();
}

// ── Filtered views ────────────────────────────────────────────────────────
final expenseCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  return ref
      .watch(categoriesProvider)
      .where((c) => c.type == 'expense' || c.type == 'both')
      .toList();
});

final incomeCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  return ref
      .watch(categoriesProvider)
      .where((c) => c.type == 'income' || c.type == 'both')
      .toList();
});
