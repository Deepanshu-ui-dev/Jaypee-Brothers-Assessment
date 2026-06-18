import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/budget_provider.dart';

class BudgetAlertBanner extends ConsumerWidget {
  const BudgetAlertBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(budgetAlertsProvider);
    if (alerts.isEmpty) return const SizedBox.shrink();

    final alert = alerts.first; // show worst one
    final isCritical = alert.pct >= 1.0;
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCritical ? context.colors.expenseRed.withAlpha(20) : Colors.orange.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical ? context.colors.expenseRed.withAlpha(100) : Colors.orange.withAlpha(100),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCritical ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
            color: isCritical ? context.colors.expenseRed : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCritical
                  ? '${alert.categoryName} budget exceeded!'
                  : '${alert.categoryName} is at ${(alert.pct * 100).toInt()}% of budget',
              style: context.textStyles.bodyMedium.copyWith(
                color: isCritical ? context.colors.expenseRed : Colors.orange[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.go('/budget'),
            style: TextButton.styleFrom(
              foregroundColor: isCritical ? context.colors.expenseRed : Colors.orange[800],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}
