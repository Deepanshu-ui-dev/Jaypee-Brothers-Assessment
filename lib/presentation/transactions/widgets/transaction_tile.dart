import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../data/models/transaction_model.dart';
import '../../transactions/add_edit_transaction_sheet.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/widgets/swipe_hint_wrapper.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.txn,
    required this.isLast,
    this.onDismissed,
    required this.categoryIcon,
    required this.categoryColor,
    required this.categoryBg,
  });

  final TransactionModel txn;
  final bool isLast;
  final VoidCallback? onDismissed;
  final IconData categoryIcon;
  final Color categoryColor;
  final Color categoryBg;

  @override
  Widget build(BuildContext context) {
    return SwipeHintWrapper(
      hintKey: 'txn_tile',
      child: Slidable(
        key: Key(txn.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.22,
          children: [
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.mediumImpact();
                onDismissed?.call();
              },
              backgroundColor: context.colors.expenseRed,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
            ),
          ],
        ),
        child: InkWell(
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
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                          color: context.colors.divider.withAlpha(80), width: 0.5)),
            ),
            child: Row(
              children: [
                // Category icon with colored background
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: categoryBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(categoryIcon, size: 18, color: categoryColor),
                ),
                const SizedBox(width: 12),
                // Name + note
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        txn.categoryName,
                        style: context.textStyles.bodyMedium.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (txn.note.isNotEmpty)
                        Text(
                          txn.note,
                          style: context.textStyles.caption.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          _timeLabel(txn.date),
                          style: context.textStyles.caption.copyWith(fontSize: 11),
                        ),
                    ],
                  ),
                ),
                // Amount + date
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${txn.isIncome ? '+' : '-'}${txn.amount.asCurrency}',
                      style: context.textStyles.bodyMedium.copyWith(
                        color: txn.isIncome
                            ? context.colors.incomeGreen
                            : context.colors.expenseRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${txn.date.day.toString().padLeft(2, '0')} ${_month(txn.date.month)}',
                      style: context.textStyles.label.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _timeLabel(DateTime dt) {
    final hour = dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h:$min $period';
  }

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}
