import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/widgets/bouncing_button.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../transactions/add_edit_transaction_sheet.dart';

class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentTransactionsProvider);

    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.primary.withAlpha(10),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.primary.withAlpha(18),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
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
                  child: const Icon(Icons.receipt_long_rounded,
                      size: 18, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('No transactions yet',
                style: context.textStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Add your first transaction to get started',
                style: context.textStyles.caption,
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 20.0,
            child: FadeInAnimation(child: widget),
          ),
          children: recent.map((txn) => _TxnRow(txn: txn)).toList(),
        ),
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn});
  final TransactionModel txn;

  @override
  Widget build(BuildContext context) {
    // Generate soft tint color based on category name lengths for visual variance, or standard if specific mapping exists
    Color getIconTint(AppColors c) {
      if (txn.categoryName.toLowerCase().contains('food')) return c.categoryFood;
      if (txn.categoryName.toLowerCase().contains('transport')) return c.categoryTransport;
      if (txn.categoryName.toLowerCase().contains('grocer')) return c.categoryGrocery;
      if (txn.categoryName.toLowerCase().contains('shop')) return c.categoryShopping;
      return txn.isIncome ? c.incomeGreen : c.categoryOthers;
    }

    return BouncingButton(
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          backgroundColor: context.colors.surface,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          builder: (_) => AddEditTransactionSheet(existing: txn),
        );
      },
      child: Container(
        height: 64,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: context.colors.subtleShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: getIconTint(context.colors).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                txn.isIncome ? Icons.arrow_downward_rounded : Icons.receipt_long_rounded,
                size: 20,
                color: getIconTint(context.colors),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    txn.note.isNotEmpty ? txn.note : txn.categoryName, 
                    style: context.textStyles.bodyMedium.copyWith(fontSize: 14),
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${txn.date.shortDate} · ${txn.categoryName}', 
                    style: context.textStyles.caption.copyWith(fontSize: 11),
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${txn.isIncome ? '+' : '-'}${txn.amount.asCurrency}',
              style: context.textStyles.heading.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: txn.isIncome
                    ? context.colors.incomeGreen
                    : context.colors.expenseRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
