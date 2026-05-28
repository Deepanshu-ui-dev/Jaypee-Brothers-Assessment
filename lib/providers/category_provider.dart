import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/category_model.dart';
import '../data/repositories/category_repository.dart';
import 'auth_provider.dart';

// ── Repository ─────────────────────────────────────────────────────────
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

// ── Categories Stream ──────────────────────────────────────────────────
final categoriesProvider =
    StreamProvider<List<CategoryModel>>((ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return const Stream.empty();

  // Seed defaults asynchronously on first load
  final repo = ref.watch(categoryRepositoryProvider);
  repo.seedDefaultsIfNeeded(user.uid);

  return repo.watchAll(user.uid);
});

// ── Expense categories only ────────────────────────────────────────────
final expenseCategoriesProvider =
    Provider<AsyncValue<List<CategoryModel>>>((ref) {
  return ref.watch(categoriesProvider).whenData(
        (cats) =>
            cats.where((c) => c.type == 'expense' || c.type == 'both').toList(),
      );
});

// ── Income categories only ─────────────────────────────────────────────
final incomeCategoriesProvider =
    Provider<AsyncValue<List<CategoryModel>>>((ref) {
  return ref.watch(categoriesProvider).whenData(
        (cats) =>
            cats.where((c) => c.type == 'income' || c.type == 'both').toList(),
      );
});

// ── Category Notifier (add / delete custom) ────────────────────────────
class CategoryNotifier extends StateNotifier<AsyncValue<void>> {
  CategoryNotifier(this._repo, this._uid) : super(const AsyncValue.data(null));

  final CategoryRepository _repo;
  final String _uid;

  Future<void> addCategory(CategoryModel category) async {
    state = const AsyncValue.loading();
    try {
      await _repo.add(_uid, category);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.delete(_uid, categoryId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, AsyncValue<void>>((ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  return CategoryNotifier(
    ref.watch(categoryRepositoryProvider),
    user?.uid ?? '',
  );
});
