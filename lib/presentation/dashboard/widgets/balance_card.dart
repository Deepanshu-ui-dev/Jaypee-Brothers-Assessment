import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/widgets/animated_number.dart';
import '../../../providers/transaction_provider.dart';
import 'animated_flow_chart.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netBalance = ref.watch(currentMonthNetBalanceProvider);
    final income = ref.watch(currentMonthIncomeProvider);
    final expense = ref.watch(currentMonthExpenseProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: context.colors.balanceCardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withAlpha(40),
            blurRadius: 20.0,
            offset: const Offset(0, 10.0),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Area
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period selector chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Net Balance: This Month',
                              style: context.textStyles.caption
                                  .copyWith(color: Colors.white70, fontSize: 11.0),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.white70, size: 14.0),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedNumber(
                        number: netBalance,
                        style: context.textStyles.displayAmountWhite,
                        prefix: NumExtension.activeCurrencySymbol,
                      ),
                    ],
                  ),
                ),
                // Flow Chart — real-time animated profit/loss
                const SizedBox(
                  width: 100,
                  height: 60,
                  child: AnimatedFlowChart(),
                )
              ],
            ),
          ),

          // Bottom Bar - Earned vs Spent Detail
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Earned
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.colors.incomeBg.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_downward_rounded,
                            color: context.colors.incomeGreen, size: 16.0),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Earned',
                                style: context.textStyles.label
                                    .copyWith(color: Colors.white70)),
                            Text(
                              income.compactCurrency,
                              style: context.textStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withAlpha(30),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                // Spent
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.colors.expenseBg.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_upward_rounded,
                            color: context.colors.expenseRed, size: 16.0),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Spent',
                                style: context.textStyles.label
                                    .copyWith(color: Colors.white70)),
                            Text(
                              expense.compactCurrency,
                              style: context.textStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
