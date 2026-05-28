import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_repository.dart';
import 'auth_provider.dart';

// ── Repository ─────────────────────────────────────────────────────────
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// ── All Transactions Stream ────────────────────────────────────────────
final transactionsProvider =
    StreamProvider<List<TransactionModel>>((ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return const Stream.empty();
  return ref.watch(transactionRepositoryProvider).watchAll(user.uid);
});

// ── Filter State ───────────────────────────────────────────────────────
enum TxnFilter { all, income, expense }

final txnFilterProvider = StateProvider<TxnFilter>((ref) => TxnFilter.all);
final txnCategoryFilterProvider = StateProvider<String?>((ref) => null);
final txnSearchQueryProvider = StateProvider<String>((ref) => '');

// ── Filtered Transactions ──────────────────────────────────────────────
final filteredTransactionsProvider =
    Provider<AsyncValue<List<TransactionModel>>>((ref) {
  final all = ref.watch(transactionsProvider);
  final filter = ref.watch(txnFilterProvider);
  final catFilter = ref.watch(txnCategoryFilterProvider);
  final query = ref.watch(txnSearchQueryProvider).toLowerCase();

  return all.whenData((txns) {
    var list = txns;
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
});

// ── Grouped by Date ────────────────────────────────────────────────────
final groupedTransactionsProvider =
    Provider<AsyncValue<Map<DateTime, List<TransactionModel>>>>((ref) {
  final filtered = ref.watch(filteredTransactionsProvider);
  return filtered.whenData((txns) {
    return groupBy(txns, (t) => DateTime(t.date.year, t.date.month, t.date.day));
  });
});

// ── Totals ─────────────────────────────────────────────────────────────
final totalIncomeProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(transactionsProvider).whenData(
        (txns) => txns
            .where((t) => t.isIncome)
            .fold(0.0, (sum, t) => sum + t.amount),
      );
});

final totalExpenseProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(transactionsProvider).whenData(
        (txns) => txns
            .where((t) => t.isExpense)
            .fold(0.0, (sum, t) => sum + t.amount),
      );
});

final netBalanceProvider = Provider<AsyncValue<double>>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);
  return income.whenData((inc) {
    return expense.when(
      data: (exp) => inc - exp,
      loading: () => inc,
      error: (_, __) => inc,
    );
  });
});

// ── Expense by Category (top 3) ────────────────────────────────────────
final expenseByCategoryProvider =
    Provider<AsyncValue<Map<String, double>>>((ref) {
  return ref.watch(transactionsProvider).whenData((txns) {
    final map = <String, double>{};
    for (final t in txns.where((t) => t.isExpense)) {
      map[t.categoryName] = (map[t.categoryName] ?? 0) + t.amount;
    }
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    return sorted;
  });
});

// ── Recent 5 Transactions ──────────────────────────────────────────────
final recentTransactionsProvider =
    Provider<AsyncValue<List<TransactionModel>>>((ref) {
  return ref.watch(transactionsProvider).whenData(
        (txns) => txns.take(5).toList(),
      );
});

// ── Monthly totals (last 6 months, for charts) ─────────────────────────
final monthlyTotalsProvider =
    Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return ref.watch(transactionsProvider).whenData((txns) {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final month = DateTime(now.year, now.month - 5 + i, 1);
      final monthTxns = txns.where((t) =>
          t.date.year == month.year && t.date.month == month.month);
      final income =
          monthTxns.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
      final expense =
          monthTxns.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
      return {'month': month, 'income': income, 'expense': expense};
    });
  });
});

// ── Current Month Analytics ────────────────────────────────────────────
final currentMonthExpenseProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(transactionsProvider).whenData((txns) {
    final now = DateTime.now();
    return txns
        .where((t) =>
            t.isExpense &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (s, t) => s + t.amount);
  });
});

final previousMonthExpenseProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(transactionsProvider).whenData((txns) {
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1);
    return txns
        .where((t) =>
            t.isExpense &&
            t.date.year == prev.year &&
            t.date.month == prev.month)
        .fold(0.0, (s, t) => s + t.amount);
  });
});

final currentMonthTxnCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(transactionsProvider).whenData((txns) {
    final now = DateTime.now();
    return txns
        .where((t) =>
            t.date.year == now.year && t.date.month == now.month)
        .length;
  });
});

// ── Previous Month Transaction Count (for comparison) ─────────────────
final previousMonthTxnCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(transactionsProvider).whenData((txns) {
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1);
    return txns
        .where((t) =>
            t.date.year == prev.year && t.date.month == prev.month)
        .length;
  });
});

// ── This Week vs Avg Weekly Spend ─────────────────────────────────────
final thisWeekExpenseProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(transactionsProvider).whenData((txns) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return txns
        .where((t) => t.isExpense && !t.date.isBefore(start))
        .fold(0.0, (s, t) => s + t.amount);
  });
});

// ── Today / Yesterday Expense ─────────────────────────────────────────
final todayExpenseProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(transactionsProvider).whenData((txns) {
    final today = DateTime.now();
    return txns
        .where((t) =>
            t.isExpense &&
            t.date.year == today.year &&
            t.date.month == today.month &&
            t.date.day == today.day)
        .fold(0.0, (s, t) => s + t.amount);
  });
});

final yesterdayExpenseProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(transactionsProvider).whenData((txns) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return txns
        .where((t) =>
            t.isExpense &&
            t.date.year == yesterday.year &&
            t.date.month == yesterday.month &&
            t.date.day == yesterday.day)
        .fold(0.0, (s, t) => s + t.amount);
  });
});

/// Top expense category name (or null if no expenses)
final topCategoryProvider = Provider<AsyncValue<String?>>((ref) {
  return ref.watch(expenseByCategoryProvider).whenData((map) {
    if (map.isEmpty) return null;
    return map.entries.first.key;
  });
});

/// Returns a human-readable weekly insight string e.g. "You've spent 12% less than your average this week"
final weeklyInsightProvider = Provider<AsyncValue<({String text, bool isPositive})>>((ref) {
  final thisWeek = ref.watch(thisWeekExpenseProvider);
  final monthly = ref.watch(monthlyTotalsProvider);
  return thisWeek.whenData((wSpend) {
    // Calculate average weekly spend from last 4 weeks (excluding current)
    final months = monthly.valueOrNull;
    if (months == null || months.isEmpty) {
      return (text: 'Track your spending to see weekly insights', isPositive: true);
    }
    // Average monthly expense over last 5 months (excluding current)
    final pastMonths = months.take(5).toList();
    final avgMonthly = pastMonths.fold(0.0, (s, m) => s + (m['expense'] as double)) /
        (pastMonths.isEmpty ? 1 : pastMonths.length);
    final avgWeekly = avgMonthly / 4.33; // average weeks per month
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
});

// ── Current Streak (consecutive days logging transactions) ──
final streakProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(transactionsProvider).whenData((txns) {
    if (txns.isEmpty) return 0;

    // Sort transactions by date descending, ignoring time
    final uniqueDates = txns
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet()
        .toList();
    uniqueDates.sort((a, b) => b.compareTo(a));

    if (uniqueDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final yesterdayOnly = todayOnly.subtract(const Duration(days: 1));

    // If they haven't logged today or yesterday, streak is broken.
    if (!uniqueDates.contains(todayOnly) &&
        !uniqueDates.contains(yesterdayOnly)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate =
        uniqueDates.contains(todayOnly) ? todayOnly : yesterdayOnly;

    while (true) {
      if (uniqueDates.contains(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  });
});

