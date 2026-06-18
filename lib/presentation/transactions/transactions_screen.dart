import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/date_extensions.dart';
import '../../core/extensions/num_extensions.dart';
import '../../core/utils/breakpoints.dart';
import '../../data/models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../core/widgets/bottom_padding.dart';
import 'widgets/transaction_tile.dart';
import 'widgets/filter_chips_bar.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = ref.watch(groupedTransactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final totals = ref.watch(filteredTotalsProvider);

    return Scaffold(
      backgroundColor: context.colors.pageBg,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: _searchOpen
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: context.textStyles.body,
                decoration: InputDecoration(
                  hintText: 'Search transactions…',
                  hintStyle: context.textStyles.caption,
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (q) {
                  ref.read(txnSearchQueryProvider.notifier).state = q;
                },
              )
            : Text('Transactions', style: context.textStyles.appBarTitle),
        actions: [
          IconButton(
            icon: Icon(
              _searchOpen ? Icons.close_rounded : Icons.search_rounded,
              size: 20,
              color: context.colors.textPrimary,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _searchOpen = !_searchOpen);
              if (!_searchOpen) {
                _searchCtrl.clear();
                ref.read(txnSearchQueryProvider.notifier).state = '';
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: context.colors.divider),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: context.isDesktop ? 800 : double.infinity),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const FilterChipsBar(),
              const SizedBox(height: 12),

              // ── Summary Totals Bar ──────────────────────────────────
              if (totals.count > 0)
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _SummaryBar(
                    income: totals.income,
                    expense: totals.expense,
                    count: totals.count,
                  ),
                ),

              Expanded(
                child: grouped.isEmpty
                    ? Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          context.colors.primary.withAlpha(10),
                                    ),
                                  ),
                                  Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          context.colors.primary.withAlpha(18),
                                    ),
                                  ),
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          context.colors.primary.withAlpha(200),
                                          context.colors.primaryDark,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Icon(
                                        Icons.receipt_long_rounded,
                                        size: 28,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Text(
                                'No transactions found',
                                style: context.textStyles.heading
                                    .copyWith(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Try a different filter, or add your first transaction.',
                                style: context.textStyles.caption
                                    .copyWith(fontSize: 14, height: 1.5),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Builder(builder: (context) {
                        final sortedDates = grouped.keys.toList()
                          ..sort((a, b) => b.compareTo(a));

                        return AnimationLimiter(
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            itemCount: sortedDates.length,
                            itemBuilder: (_, i) {
                              final date = sortedDates[i];
                              final txns = grouped[date]!;

                              return AnimationConfiguration.staggeredList(
                                position: i,
                                duration:
                                    const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 20.0,
                                  child: FadeInAnimation(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20, bottom: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Text(
                                                date.groupLabel
                                                    .toUpperCase(),
                                                style: context.textStyles
                                                    .sectionHeader
                                                    .copyWith(
                                                  letterSpacing: 0.5,
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                ),
                                              ),
                                              // Daily total
                                              Text(
                                                _dailyTotal(txns),
                                                style: context.textStyles
                                                    .caption
                                                    .copyWith(
                                                  fontSize: 11,
                                                  color: context
                                                      .colors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: context.colors.surface,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: context.colors.divider
                                                  .withAlpha(128),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            children: txns
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              final txn = entry.value;
                                              final isLast = entry.key ==
                                                  txns.length - 1;

                                              final cat = categories
                                                  .where((c) =>
                                                      c.id == txn.categoryId)
                                                  .toList();
                                              final icon = cat.isNotEmpty
                                                  ? cat.first.icon
                                                  : (txn.isIncome
                                                      ? Icons
                                                          .arrow_upward_rounded
                                                      : Icons
                                                          .arrow_downward_rounded);
                                              final color = cat.isNotEmpty
                                                  ? cat.first.color
                                                  : (txn.isIncome
                                                      ? context
                                                          .colors.incomeGreen
                                                      : context
                                                          .colors.expenseRed);
                                              final bg = cat.isNotEmpty
                                                  ? cat.first
                                                      .themedBgColor(context)
                                                  : (txn.isIncome
                                                      ? context
                                                          .colors.incomeBg
                                                      : context
                                                          .colors.expenseBg);

                                              return TransactionTile(
                                                txn: txn,
                                                isLast: isLast,
                                                categoryIcon: icon,
                                                categoryColor: color,
                                                categoryBg: bg,
                                                onDismissed: () async {
                                                  await ref
                                                      .read(
                                                          transactionNotifierProvider
                                                              .notifier)
                                                      .delete(txn.id);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .clearSnackBars();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                            'Transaction deleted'),
                                                        action:
                                                            SnackBarAction(
                                                          label: 'UNDO',
                                                          onPressed: () {
                                                            ref
                                                                .read(
                                                                    transactionNotifierProvider
                                                                        .notifier)
                                                                .restore(txn);
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
              ),
              const BottomPadding(minimum: 100),
            ],
          ),
        ),
      ),
    );
  }

  String _dailyTotal(List<dynamic> txns) {
    double total = 0;
    for (final t in txns) {
      total += t.isIncome ? t.amount : -t.amount;
    }
    final sym = NumExtension.activeCurrencySymbol;
    if (total >= 0) return '+$sym${total.abs().toStringAsFixed(0)}';
    return '-$sym${total.abs().toStringAsFixed(0)}';
  }
}

// ── Summary Bar ─────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.income,
    required this.expense,
    required this.count,
  });

  final double income;
  final double expense;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: context.colors.divider.withAlpha(128), width: 1),
      ),
      child: Row(
        children: [
          // Count
          Expanded(
            child: _SummaryCell(
              label: 'Entries',
              value: '$count',
              color: context.colors.textSecondary,
              icon: Icons.list_alt_rounded,
            ),
          ),
          Container(width: 1, height: 32, color: context.colors.divider),
          // Income
          Expanded(
            child: _SummaryCell(
              label: 'Income',
              value: income.compactCurrency,
              color: context.colors.incomeGreen,
              icon: Icons.arrow_downward_rounded,
            ),
          ),
          Container(width: 1, height: 32, color: context.colors.divider),
          // Expense
          Expanded(
            child: _SummaryCell(
              label: 'Expense',
              value: expense.compactCurrency,
              color: context.colors.expenseRed,
              icon: Icons.arrow_upward_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.textStyles.caption.copyWith(
                fontSize: 10,
                color: context.colors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: context.textStyles.heading.copyWith(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
