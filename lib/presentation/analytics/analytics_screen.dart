import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/num_extensions.dart';
import '../../providers/transaction_provider.dart';
import 'widgets/category_breakdown_list.dart';
import 'widgets/monthly_bar_chart.dart';
import 'widgets/daily_line_chart.dart';
import '../../core/widgets/bottom_padding.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentExpense = ref.watch(currentMonthExpenseProvider);
    final previousExpense = ref.watch(previousMonthExpenseProvider);
    final txnCount = ref.watch(currentMonthTxnCountProvider);
    final prevTxnCount = ref.watch(previousMonthTxnCountProvider);
    final income = ref.watch(totalIncomeProvider);

    final now = DateTime.now();
    final dayOfMonth = now.day;
    final monthName = _monthName(now.month);

    final dailyAvg = dayOfMonth > 0 ? currentExpense / dayOfMonth : 0.0;
    final prevDays = _daysInPreviousMonth(now);
    final prevDailyAvg = prevDays > 0 ? previousExpense / prevDays : 0.0;
    final net = income - currentExpense;
    final categoryBreakdown = ref.watch(categoryBreakdownProvider);
    final topCategory = categoryBreakdown.isNotEmpty ? categoryBreakdown.first : null;
    final savingsRate = income > 0 ? ((income - currentExpense) / income * 100).clamp(0.0, 100.0) : 0.0;
    final projectedMonthly = dayOfMonth > 0 ? (currentExpense / dayOfMonth) * _daysInMonth(now) : 0.0;

    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: SafeArea(
        child: AnimationLimiter(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 450),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 40.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                // ── Header ──
                _AnalyticsHeader(monthName: monthName),
                const SizedBox(height: 24),

                // ── Hero Net Card ──
                _NetSummaryCard(
                  income: income,
                  expense: currentExpense,
                  net: net,
                  monthName: monthName,
                  daysElapsed: dayOfMonth,
                ),
                const SizedBox(height: 20),

                // ── Stat Pills ──
                Row(
                  children: [
                    Expanded(
                      child: _StatPill(
                        title: 'Total Spent',
                        value: currentExpense.asCurrency,
                        subtitle: _comparisonLabel(currentExpense, previousExpense),
                        icon: Icons.credit_card_rounded,
                        iconTint: context.colors.primary,
                        subtitlePositive: currentExpense <= previousExpense,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatPill(
                        title: 'Daily Avg.',
                        value: dailyAvg.asCurrency,
                        subtitle: _comparisonLabel(dailyAvg, prevDailyAvg),
                        icon: Icons.access_time_rounded,
                        iconTint: context.colors.categoryShopping,
                        subtitlePositive: dailyAvg <= prevDailyAvg,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatPill(
                        title: 'Entries',
                        value: '$txnCount',
                        subtitle: _entriesLabel(txnCount, prevTxnCount),
                        icon: Icons.list_alt_rounded,
                        iconTint: context.colors.categoryData,
                        subtitlePositive: txnCount >= prevTxnCount,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Insight Cards Row ──
                Row(
                  children: [
                    Expanded(
                      child: _InsightMiniCard(
                        icon: Icons.savings_rounded,
                        iconColor: const Color(0xFF34D399),
                        label: 'Savings Rate',
                        value: '${savingsRate.toStringAsFixed(1)}%',
                        isPositive: savingsRate >= 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InsightMiniCard(
                        icon: Icons.trending_up_rounded,
                        iconColor: const Color(0xFFFF9500),
                        label: 'Projected',
                        value: projectedMonthly.compactCurrency,
                        isPositive: projectedMonthly <= previousExpense,
                      ),
                    ),
                    if (topCategory != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InsightMiniCard(
                          icon: Icons.category_rounded,
                          iconColor: context.colors.categoryFood,
                          label: 'Top Category',
                          value: topCategory.name,
                          isPositive: true,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 32),

                // ── Daily Trend ──
                _SectionHeader(title: 'Daily Spending', subtitle: 'This month so far'),
                const SizedBox(height: 12),
                _ChartCard(child: const DailyLineChart()),
                const SizedBox(height: 32),

                // ── Category Breakdown ──
                _SectionHeader(title: 'Category Breakdown', subtitle: 'Where your money goes'),
                const SizedBox(height: 12),
                _ChartCard(
                  padding: const EdgeInsets.all(20),
                  child: const CategoryBreakdownList(),
                ),
                const SizedBox(height: 32),

                // ── 6-Month Trend ──
                _SectionHeader(
                  title: '6-Month Trend',
                  subtitle: 'Income vs expenses',
                  trailing: Row(
                    children: [
                      _Legend(color: context.colors.primary, label: 'Income'),
                      const SizedBox(width: 12),
                      _Legend(color: context.colors.expenseRed.withAlpha(180), label: 'Expense'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _ChartCard(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                  child: const MonthlyBarChart(),
                ),
                //const BottomPadding(minimum: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month];
  }

  int _daysInPreviousMonth(DateTime now) =>
      DateTime(now.year, now.month, 0).day;

  int _daysInMonth(DateTime now) =>
      DateTime(now.year, now.month + 1, 0).day;

  String _comparisonLabel(double current, double previous) {
    if (previous <= 0) return '—';
    final diff = current - previous;
    if (diff == 0) return 'Same as last month';
    final pct = ((diff.abs() / previous) * 100).toStringAsFixed(0);
    return '${diff < 0 ? '↓' : '↑'} $pct% vs last month';
  }

  String _entriesLabel(int count, int prev) {
    final diff = count - prev;
    if (diff == 0) return 'Same as last month';
    return '${diff > 0 ? '↑' : '↓'} ${diff.abs()} vs last month';
  }
}


// ── Insight Mini Card ────────────────────────────────────────────────────────

class _InsightMiniCard extends StatelessWidget {
  const _InsightMiniCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isPositive,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.divider.withAlpha(80)),
        boxShadow: context.colors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: context.textStyles.subheading.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isPositive ? iconColor : context.colors.expenseRed,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.textStyles.caption.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _AnalyticsHeader extends StatelessWidget {
  final String monthName;
  const _AnalyticsHeader({required this.monthName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics',
              style: context.textStyles.heading.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Your spending at a glance',
              style: context.textStyles.caption.copyWith(
                color: context.colors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: context.colors.insightBannerBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: context.colors.primary.withAlpha(50),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month_rounded,
                  size: 14, color: context.colors.insightBannerText),
              const SizedBox(width: 6),
              Text(
                monthName,
                style: context.textStyles.bodyMedium.copyWith(
                  color: context.colors.insightBannerText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Net Summary Card ─────────────────────────────────────────────────────────

class _NetSummaryCard extends StatelessWidget {
  final double income;
  final double expense;
  final double net;
  final String monthName;
  final int daysElapsed;

  const _NetSummaryCard({
    required this.income,
    required this.expense,
    required this.net,
    required this.monthName,
    required this.daysElapsed,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = net >= 0;
    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: colors.balanceCardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: colors.primaryGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Balance',
                style: styles.caption.copyWith(
                  color: Colors.white.withAlpha(180),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Day $daysElapsed · $monthName',
                  style: styles.label.copyWith(
                    color: Colors.white.withAlpha(200),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                net.abs().asCurrency,
                style: styles.heading.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.white.withAlpha(30)
                        : colors.expenseRed.withAlpha(80),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPositive ? '↑ Surplus' : '↓ Deficit',
                    style: styles.label.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _NetRow(
                  label: 'Income',
                  value: income.asCurrency,
                  icon: Icons.arrow_downward_rounded,
                  iconColor: colors.incomeGreen,
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white.withAlpha(40)),
              Expanded(
                child: _NetRow(
                  label: 'Expenses',
                  value: expense.asCurrency,
                  icon: Icons.arrow_upward_rounded,
                  iconColor: Colors.white.withAlpha(180),
                  align: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final CrossAxisAlignment align;

  const _NetRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final isEnd = align == CrossAxisAlignment.end;
    return Padding(
      padding: EdgeInsets.only(left: isEnd ? 16 : 0, right: isEnd ? 0 : 16),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment:
                isEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Icon(icon, size: 11, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: context.textStyles.label.copyWith(
                  color: Colors.white.withAlpha(160),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: context.textStyles.heading.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textStyles.subheading.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: context.textStyles.caption.copyWith(
                color: context.colors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ── Chart Card wrapper ───────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _ChartCard({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.divider, width: 0.5),
        boxShadow: context.colors.subtleShadow,
      ),
      child: child,
    );
  }
}

// ── Stat Pill ────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconTint,
    this.subtitlePositive = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconTint;
  final bool subtitlePositive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.divider, width: 0.5),
        boxShadow: colors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconTint.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 14, color: iconTint),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: styles.label.copyWith(
              fontSize: 10,
              color: colors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: styles.heading.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: styles.label.copyWith(
              fontSize: 9,
              color: subtitlePositive ? colors.incomeGreen : colors.expenseRed,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Legend ───────────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label,
            style: context.textStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }
}
