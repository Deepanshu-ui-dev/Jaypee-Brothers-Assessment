import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/num_extensions.dart';
import '../../data/models/category_model.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../core/widgets/bouncing_button.dart';
import 'set_budget_sheet.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(expenseCategoriesProvider);
    final budgets = ref.watch(budgetNotifierProvider);

    final sortedCategories = [...categories]..sort((a, b) {
        final aHasBudget = budgets.any((bg) => bg.categoryId == a.id);
        final bHasBudget = budgets.any((bg) => bg.categoryId == b.id);
        if (aHasBudget && !bHasBudget) return -1;
        if (!aHasBudget && bHasBudget) return 1;
        return a.name.compareTo(b.name);
      });

    final now = DateTime.now();
    final monthName = const [
      '',
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][now.month];

    double totalLimit = 0;
    double totalSpent = 0;
    for (final cat in categories) {
      final spendData = ref.watch(categorySpendVsBudgetProvider(cat.id));
      if (spendData.limit > 0) {
        totalLimit += spendData.limit;
        totalSpent += spendData.spent;
      }
    }
    final overallPct =
        totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;
    final budgetsSetCount = budgets.length;

    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: budgets.isEmpty && sortedCategories.isEmpty
          ? const _EmptyState()
          : AnimationLimiter(
              child: CustomScrollView(
                slivers: [
                SliverToBoxAdapter(
                  child: _BudgetHeader(
                    monthName: monthName,
                    totalLimit: totalLimit,
                    totalSpent: totalSpent,
                    overallPct: overallPct,
                    budgetsSetCount: budgetsSetCount,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, index) {
                        final cat = sortedCategories[index];
                        final spendData =
                            ref.watch(categorySpendVsBudgetProvider(cat.id));
                        final hasBudget = spendData.limit > 0;

                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 400),
                          child: SlideAnimation(
                            verticalOffset: 24.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _BudgetCard(
                                  categoryName: cat.name,
                                  categoryIcon: cat.icon,
                                  iconColor: cat.color,
                                  iconBg: cat.themedBgColor(ctx),
                                  spent: spendData.spent,
                                  limit: spendData.limit,
                                  pct: spendData.pct,
                                  hasBudget: hasBudget,
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: context.colors.surface,
                                      isScrollControlled: true,
                                      useRootNavigator: true,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(28))),
                                      builder: (_) => SetBudgetSheet(
                                        categoryId: cat.id,
                                        categoryName: cat.name,
                                        categoryIcon: cat.icon,
                                        iconColor: cat.color,
                                        iconBg: cat.themedBgColor(context),
                                        currentLimit: spendData.limit,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: sortedCategories.length,
                    ),
                  ),
                ),
              ],
              ),
            ),
    );
  }
}

// ── Budget Summary Header ─────────────────────────────────────────────────

class _BudgetHeader extends StatelessWidget {
  const _BudgetHeader({
    required this.monthName,
    required this.totalLimit,
    required this.totalSpent,
    required this.overallPct,
    required this.budgetsSetCount,
  });

  final String monthName;
  final double totalLimit;
  final double totalSpent;
  final double overallPct;
  final int budgetsSetCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Goals',
                      style: context.textStyles.heading.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      monthName,
                      style: context.textStyles.caption.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: context.colors.primary.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded,
                          size: 14, color: context.colors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '$budgetsSetCount active',
                        style: context.textStyles.label.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Summary Card ──────────────────────────────────────────
          if (totalLimit > 0) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary,
                      context.colors.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: context.colors.primaryGlow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Spent',
                              style: context.textStyles.caption.copyWith(
                                color: Colors.white.withAlpha(180),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalSpent.compactCurrency,
                              style: context.textStyles.displayAmount.copyWith(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Remaining',
                              style: context.textStyles.caption.copyWith(
                                color: Colors.white.withAlpha(180),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              overallPct >= 1.0
                                  ? 'Over budget!'
                                  : (totalLimit - totalSpent).compactCurrency,
                              style: context.textStyles.displayAmount.copyWith(
                                color: overallPct >= 1.0
                                    ? const Color(0xFFFFD580)
                                    : Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: overallPct),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (_, val, __) => Stack(
                        children: [
                          Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withAlpha(30), width: 1),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: val,
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.white, Color(0xFFF1F5F9)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withAlpha(60),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(overallPct * 100).toStringAsFixed(0)}% of budget used',
                          style: context.textStyles.caption.copyWith(
                            color: Colors.white.withAlpha(200),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'of ${totalLimit.compactCurrency}',
                          style: context.textStyles.caption.copyWith(
                            color: Colors.white.withAlpha(200),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Categories', style: context.textStyles.subheading),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
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
                    color: context.colors.primary.withAlpha(10),
                  ),
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.primary.withAlpha(18),
                  ),
                ),
                Container(
                  width: 64,
                  height: 64,
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
                  child: const Icon(Icons.track_changes_rounded,
                      size: 30, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'No budget goals yet',
              style: context.textStyles.heading.copyWith(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Tap any category to set a spending limit and take control of your finances.',
              style:
                  context.textStyles.caption.copyWith(fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Budget Card ──────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.categoryName,
    required this.categoryIcon,
    required this.iconColor,
    required this.iconBg,
    required this.spent,
    required this.limit,
    required this.pct,
    required this.hasBudget,
    required this.onTap,
  });

  final String categoryName;
  final IconData categoryIcon;
  final Color iconColor;
  final Color iconBg;
  final double spent;
  final double limit;
  final double pct;
  final bool hasBudget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color progressColor = context.colors.incomeGreen;
    String statusText = '${(pct * 100).toStringAsFixed(0)}% used';
    if (pct >= 1.0) {
      progressColor = context.colors.expenseRed;
      statusText = 'Budget exceeded!';
    } else if (pct >= 0.85) {
      progressColor = const Color(0xFFFF9500);
      statusText = '${(pct * 100).toStringAsFixed(0)}% — almost there';
    }

    return BouncingButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.colors.surface,
              context.colors.surface.withAlpha(220),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: hasBudget && pct >= 0.85
                ? progressColor.withAlpha(120)
                : context.colors.divider.withAlpha(50),
            width: hasBudget && pct >= 0.85 ? 1.5 : 0.8,
          ),
          boxShadow: [
            if (hasBudget && pct >= 0.85)
              BoxShadow(
                color: progressColor.withAlpha(30),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ...context.colors.subtleShadow,
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(categoryIcon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(categoryName,
                          style: context.textStyles.bodyMedium
                              .copyWith(fontSize: 15)),
                      const SizedBox(height: 2),
                      if (hasBudget)
                        Text(
                          statusText,
                          style: context.textStyles.caption.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        )
                      else
                        Text('Tap to set a budget limit',
                            style: context.textStyles.caption
                                .copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                if (hasBudget)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        spent.asCurrency,
                        style: context.textStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: progressColor,
                        ),
                      ),
                      Text(
                        'of ${limit.asCurrency}',
                        style: context.textStyles.caption
                            .copyWith(fontSize: 12),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Set Limit',
                      style: context.textStyles.label.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            if (hasBudget) ...[
              const SizedBox(height: 16),
              _AnimatedProgressBar(
                pct: pct,
                color: progressColor,
                backgroundColor: context.colors.pageBg,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spent',
                    style: context.textStyles.caption.copyWith(fontSize: 11),
                  ),
                  Text(
                    pct >= 1.0
                        ? 'Over by ${(spent - limit).asCurrency}'
                        : '${(limit - spent).asCurrency} remaining',
                    style: context.textStyles.caption.copyWith(
                      fontSize: 11,
                      color: pct >= 1.0
                          ? context.colors.expenseRed
                          : context.colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Animated Progress Bar ─────────────────────────────────────────────────

class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({
    required this.pct,
    required this.color,
    required this.backgroundColor,
  });

  final double pct;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: pct.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            FractionallySizedBox(
              widthFactor: value,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withAlpha(180),
                      color,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(80),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
