import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_repository.dart';

// ── Repository ────────────────────────────────────────────────────────────
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// ── All Transactions (Hive-backed StateNotifier) ──────────────────────────
class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier(this._repo) : super([]) {
    _load();
  }

  final TransactionRepository _repo;

  void _load() {
    state = _repo.getAll();
  }

  Future<void> add(TransactionModel txn) async {
    await _repo.add(txn);
    _load();
  }

  Future<void> update(TransactionModel txn) async {
    await _repo.update(txn);
    _load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    _load();
  }

  Future<void> restore(TransactionModel txn) async {
    await _repo.add(txn);
    _load();
  }

  void reload() => _load();
}

final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  return TransactionNotifier(ref.watch(transactionRepositoryProvider));
});

// ── Filter State ──────────────────────────────────────────────────────────
enum TxnFilter { all, income, expense }

final txnFilterProvider = StateProvider<TxnFilter>((ref) => TxnFilter.all);
final txnCategoryFilterProvider = StateProvider<String?>((ref) => null);
final txnSearchQueryProvider = StateProvider<String>((ref) => '');

// ── Filtered Transactions ─────────────────────────────────────────────────
final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final all = ref.watch(transactionNotifierProvider);
  final filter = ref.watch(txnFilterProvider);
  final catFilter = ref.watch(txnCategoryFilterProvider);
  final query = ref.watch(txnSearchQueryProvider).toLowerCase();

  var list = all;
  if (filter == TxnFilter.income) {
    list = list.where((t) => t.isIncome).toList();
  } else if (filter == TxnFilter.expense) {
    list = list.where((t) => t.isExpense).toList();
  }
  if (catFilter != null) {
    list = list.where((t) => t.categoryId == catFilter).toList();
  }
  if (query.isNotEmpty) {
    list = list
        .where((t) =>
            t.note.toLowerCase().contains(query) ||
            t.categoryName.toLowerCase().contains(query))
        .toList();
  }
  return list;
});

// ── Grouped by Date ───────────────────────────────────────────────────────
final groupedTransactionsProvider =
    Provider<Map<DateTime, List<TransactionModel>>>((ref) {
  final filtered = ref.watch(filteredTransactionsProvider);
  return groupBy(
      filtered, (t) => DateTime(t.date.year, t.date.month, t.date.day));
});

// ── Filtered Totals (for summary bar on transactions screen) ──────────────
({double income, double expense, int count}) filteredTotals(
    List<TransactionModel> list) {
  double income = 0;
  double expense = 0;
  for (final t in list) {
    if (t.isIncome) {
      income += t.amount;
    } else {
      expense += t.amount;
    }
  }
  return (income: income, expense: expense, count: list.length);
}

final filteredTotalsProvider =
    Provider<({double income, double expense, int count})>((ref) {
  final list = ref.watch(filteredTransactionsProvider);
  return filteredTotals(list);
});

// ── Totals ────────────────────────────────────────────────────────────────
final totalIncomeProvider = Provider<double>((ref) {
  return ref
      .watch(transactionNotifierProvider)
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final totalExpenseProvider = Provider<double>((ref) {
  return ref
      .watch(transactionNotifierProvider)
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final netBalanceProvider = Provider<double>((ref) {
  return ref.watch(totalIncomeProvider) - ref.watch(totalExpenseProvider);
});

// ── Expense by Category ───────────────────────────────────────────────────
final expenseByCategoryProvider = Provider<Map<String, double>>((ref) {
  final txns = ref.watch(transactionNotifierProvider);
  final map = <String, double>{};
  for (final t in txns.where((t) => t.isExpense)) {
    map[t.categoryName] = (map[t.categoryName] ?? 0) + t.amount;
  }
  final sorted = Map.fromEntries(
    map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
  );
  return sorted;
});

// ── Recent 5 Transactions ─────────────────────────────────────────────────
final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(transactionNotifierProvider).take(5).toList();
});

// ── Monthly totals (last 6 months) ───────────────────────────────────────
final monthlyTotalsProvider =
    Provider<List<Map<String, dynamic>>>((ref) {
  final txns = ref.watch(transactionNotifierProvider);
  final now = DateTime.now();
  return List.generate(6, (i) {
    final month = DateTime(now.year, now.month - 5 + i, 1);
    final monthTxns = txns.where(
        (t) => t.date.year == month.year && t.date.month == month.month);
    final income =
        monthTxns.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final expense =
        monthTxns.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
    return {'month': month, 'income': income, 'expense': expense};
  });
});

// ── Current Month Providers ───────────────────────────────────────────────
final currentMonthExpenseProvider = Provider<double>((ref) {
  final now = DateTime.now();
  return ref.watch(transactionNotifierProvider).where((t) =>
      t.isExpense && t.date.year == now.year && t.date.month == now.month).fold(0.0, (s, t) => s + t.amount);
});

final previousMonthExpenseProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final prev = DateTime(now.year, now.month - 1);
  return ref.watch(transactionNotifierProvider).where((t) =>
      t.isExpense && t.date.year == prev.year && t.date.month == prev.month).fold(0.0, (s, t) => s + t.amount);
});

final currentMonthTxnCountProvider = Provider<int>((ref) {
  final now = DateTime.now();
  return ref.watch(transactionNotifierProvider)
      .where((t) => t.date.year == now.year && t.date.month == now.month)
      .length;
});

final previousMonthTxnCountProvider = Provider<int>((ref) {
  final now = DateTime.now();
  final prev = DateTime(now.year, now.month - 1);
  return ref.watch(transactionNotifierProvider)
      .where((t) => t.date.year == prev.year && t.date.month == prev.month)
      .length;
});

// ── This Week Expense ─────────────────────────────────────────────────────
final thisWeekExpenseProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
  return ref.watch(transactionNotifierProvider)
      .where((t) => t.isExpense && !t.date.isBefore(start))
      .fold(0.0, (s, t) => s + t.amount);
});

// ── Today / Yesterday Expense ─────────────────────────────────────────────
final todayExpenseProvider = Provider<double>((ref) {
  final today = DateTime.now();
  return ref.watch(transactionNotifierProvider).where((t) =>
      t.isExpense &&
      t.date.year == today.year &&
      t.date.month == today.month &&
      t.date.day == today.day).fold(0.0, (s, t) => s + t.amount);
});

final yesterdayExpenseProvider = Provider<double>((ref) {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return ref.watch(transactionNotifierProvider).where((t) =>
      t.isExpense &&
      t.date.year == yesterday.year &&
      t.date.month == yesterday.month &&
      t.date.day == yesterday.day).fold(0.0, (s, t) => s + t.amount);
});

// ── Top Category ──────────────────────────────────────────────────────────
final topCategoryProvider = Provider<String?>((ref) {
  final map = ref.watch(expenseByCategoryProvider);
  return map.isEmpty ? null : map.entries.first.key;
});

// ── Daily Spending (current month) ────────────────────────────────────────
final dailySpendingProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final txns = ref.watch(transactionNotifierProvider);
  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

  return List.generate(daysInMonth, (i) {
    final day = i + 1;
    final amount = txns
        .where((t) =>
            t.isExpense &&
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == day)
        .fold(0.0, (s, t) => s + t.amount);
    return {'day': day, 'amount': amount};
  });
});

// ── Weekly Insight ────────────────────────────────────────────────────────
final weeklyInsightProvider =
    Provider<({String text, bool isPositive})>((ref) {
  final wSpend = ref.watch(thisWeekExpenseProvider);
  final months = ref.watch(monthlyTotalsProvider);

  if (months.isEmpty) {
    return (text: 'Track your spending to see weekly insights', isPositive: true);
  }
  final pastMonths = months.take(5).toList();
  final avgMonthly = pastMonths.fold(0.0, (s, m) => s + (m['expense'] as double)) /
      (pastMonths.isEmpty ? 1 : pastMonths.length);
  final avgWeekly = avgMonthly / 4.33;
  if (avgWeekly <= 0) {
    return (text: 'Start spending to see your weekly insights', isPositive: true);
  }
  final diff = wSpend - avgWeekly;
  final pct = ((diff / avgWeekly) * 100).abs().toStringAsFixed(0);
  if (diff < 0) {
    return (text: "You've spent $pct% less than your weekly average 🎯", isPositive: true);
  } else if (diff == 0) {
    return (text: "You're right on track with your weekly average", isPositive: true);
  } else {
    return (text: "You've spent $pct% more than your weekly average — keep an eye out!", isPositive: false);
  }
});

// ── Streak ────────────────────────────────────────────────────────────────
final streakProvider = Provider<int>((ref) {
  final txns = ref.watch(transactionNotifierProvider);
  if (txns.isEmpty) return 0;

  final uniqueDates = txns
      .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  if (uniqueDates.isEmpty) return 0;

  final today = DateTime.now();
  final todayOnly = DateTime(today.year, today.month, today.day);
  final yesterdayOnly = todayOnly.subtract(const Duration(days: 1));

  if (!uniqueDates.contains(todayOnly) && !uniqueDates.contains(yesterdayOnly)) {
    return 0;
  }

  int streak = 0;
  DateTime checkDate =
      uniqueDates.contains(todayOnly) ? todayOnly : yesterdayOnly;

  while (uniqueDates.contains(checkDate)) {
    streak++;
    checkDate = checkDate.subtract(const Duration(days: 1));
  }
  return streak;
});
