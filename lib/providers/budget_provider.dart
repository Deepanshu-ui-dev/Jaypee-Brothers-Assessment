import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/budget_model.dart';
import '../data/repositories/budget_repository.dart';
import 'transaction_provider.dart';

// ── Repository ────────────────────────────────────────────────────────────
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

// ── Budget Notifier ───────────────────────────────────────────────────────
class BudgetNotifier extends StateNotifier<List<BudgetModel>> {
  BudgetNotifier(this._repo) : super([]) {
    _load();
  }

  final BudgetRepository _repo;

  void _load() {
    final now = DateTime.now();
    state = _repo.getForMonth(now.year, now.month);
  }

  Future<void> setBudget({
    required String categoryId,
    required String categoryName,
    required double limit,
  }) async {
    final now = DateTime.now();
    final budget = BudgetModel(
      id: BudgetModel.makeId(categoryId, now.year, now.month),
      categoryId: categoryId,
      categoryName: categoryName,
      limitAmount: limit,
      month: now.month,
      year: now.year,
    );
    await _repo.set(budget);
    _load();
  }

  Future<void> deleteBudget(String categoryId) async {
    final now = DateTime.now();
    await _repo.delete(categoryId, now.year, now.month);
    _load();
  }

  void reload() => _load();
}

final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, List<BudgetModel>>((ref) {
  return BudgetNotifier(ref.watch(budgetRepositoryProvider));
});

// ── Budget for a specific category (current month) ───────────────────────
final budgetForCategoryProvider =
    Provider.family<BudgetModel?, String>((ref, categoryId) {
  final budgets = ref.watch(budgetNotifierProvider);
  try {
    return budgets.firstWhere((b) => b.categoryId == categoryId);
  } catch (_) {
    return null;
  }
});

// ── Spend vs Budget (spent, limit, pct) for a category ───────────────────
final categorySpendVsBudgetProvider =
    Provider.family<({double spent, double limit, double pct}), String>(
        (ref, categoryId) {
  final txns = ref.watch(transactionNotifierProvider);
  final budget = ref.watch(budgetForCategoryProvider(categoryId));
  final now = DateTime.now();

  final spent = txns
      .where((t) =>
          t.isExpense &&
          t.categoryId == categoryId &&
          t.date.year == now.year &&
          t.date.month == now.month)
      .fold(0.0, (s, t) => s + t.amount);

  final limit = budget?.limitAmount ?? 0;
  final pct = limit > 0 ? (spent / limit).clamp(0.0, 2.0) : 0.0;
  return (spent: spent, limit: limit, pct: pct);
});

// ── Alerts — categories over 80% of budget ───────────────────────────────
final budgetAlertsProvider =
    Provider<List<({String categoryId, String categoryName, double pct})>>((ref) {
  final budgets = ref.watch(budgetNotifierProvider);
  final txns = ref.watch(transactionNotifierProvider);
  final now = DateTime.now();

  final alerts = <({String categoryId, String categoryName, double pct})>[];

  for (final budget in budgets) {
    final spent = txns
        .where((t) =>
            t.isExpense &&
            t.categoryId == budget.categoryId &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (s, t) => s + t.amount);

    final pct = budget.limitAmount > 0
        ? (spent / budget.limitAmount).clamp(0.0, 2.0)
        : 0.0;

    if (pct >= 0.85) {
      alerts.add((
        categoryId: budget.categoryId,
        categoryName: budget.categoryName,
        pct: pct,
      ));
    }
  }

  alerts.sort((a, b) => b.pct.compareTo(a.pct));
  return alerts;
});

// ── Projected % if new amount is added ───────────────────────────────────
final projectedBudgetPctProvider =
    Provider.family<double?, ({String categoryId, double newAmount})>(
        (ref, args) {
  final budget =
      ref.watch(budgetForCategoryProvider(args.categoryId));
  if (budget == null || budget.limitAmount <= 0) return null;

  final data = ref.watch(categorySpendVsBudgetProvider(args.categoryId));
  final projected = data.spent + args.newAmount;
  return (projected / budget.limitAmount).clamp(0.0, 5.0);
});
