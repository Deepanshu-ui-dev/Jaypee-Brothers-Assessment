import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/num_extensions.dart';
import '../../providers/budget_provider.dart';

class SetBudgetSheet extends ConsumerStatefulWidget {
  const SetBudgetSheet({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.iconColor,
    required this.iconBg,
    required this.currentLimit,
  });

  final String categoryId;
  final String categoryName;
  final IconData categoryIcon;
  final Color iconColor;
  final Color iconBg;
  final double currentLimit;

  @override
  ConsumerState<SetBudgetSheet> createState() => _SetBudgetSheetState();
}

class _SetBudgetSheetState extends ConsumerState<SetBudgetSheet>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _amountCtrl;
  late final FocusNode _focusNode;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final List<int> _presets = [1000, 5000, 10000, 25000, 50000];

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.currentLimit > 0
          ? widget.currentLimit.toStringAsFixed(0)
          : '',
    );
    _focusNode = FocusNode();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Auto-focus after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _focusNode.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(int amount) {
    HapticFeedback.selectionClick();
    setState(() {
      _amountCtrl.text = amount.toString();
      _amountCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountCtrl.text.length),
      );
    });
  }

  void _save() {
    final raw = _amountCtrl.text.replaceAll(',', '').replaceAll(' ', '');
    final limit = double.tryParse(raw) ?? 0;
    HapticFeedback.mediumImpact();
    if (limit <= 0) {
      ref
          .read(budgetNotifierProvider.notifier)
          .deleteBudget(widget.categoryId);
    } else {
      ref.read(budgetNotifierProvider.notifier).setBudget(
            categoryId: widget.categoryId,
            categoryName: widget.categoryName,
            limit: limit,
          );
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    HapticFeedback.heavyImpact();
    ref
        .read(budgetNotifierProvider.notifier)
        .deleteBudget(widget.categoryId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final currencySymbol = NumExtension.activeCurrencySymbol;

    return Container(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Category Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: widget.iconBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(widget.categoryIcon,
                      color: widget.iconColor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Limit',
                        style: context.textStyles.caption.copyWith(
                          color: context.colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.categoryName,
                        style:
                            context.textStyles.heading.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                if (widget.currentLimit > 0)
                  GestureDetector(
                    onTap: _delete,
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: context.colors.expenseRed.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.colors.expenseRed.withAlpha(40),
                        ),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: context.colors.expenseRed,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Big Amount Input ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
            child: ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: context.colors.pageBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.colors.primary.withAlpha(60),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$currencySymbol ',
                      style: context.textStyles.heading.copyWith(
                        fontSize: 28,
                        color: context.colors.textMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountCtrl,
                        focusNode: _focusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.center,
                        style: context.textStyles.displayAmount.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.5,
                          color: context.colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: context.textStyles.displayAmount.copyWith(
                            fontSize: 40,
                            fontWeight: FontWeight.w300,
                            color: context.colors.textMuted.withAlpha(100),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 80),
                        ),
                        onSubmitted: (_) => _save(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Preset Chips ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _presets.map((amount) {
                  final isSelected =
                      _amountCtrl.text == amount.toString();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _applyPreset(amount),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? context.colors.primary
                                : context.colors.divider,
                          ),
                        ),
                        child: Text(
                          '$currencySymbol ${_formatPreset(amount)}',
                          style: context.textStyles.label.copyWith(
                            color: isSelected
                                ? Colors.white
                                : context.colors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Divider ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: context.colors.divider, height: 1),
          ),
          const SizedBox(height: 16),

          // ── Save Button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.colors.primary,
                        context.colors.primaryDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.primary.withAlpha(80),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.currentLimit > 0
                            ? 'Update Budget'
                            : 'Set Budget',
                        style: context.textStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPreset(int amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(0)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }
}
