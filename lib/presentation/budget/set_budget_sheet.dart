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
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _animCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _focusNode.dispose();
    _animCtrl.dispose();
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
      ref.read(budgetNotifierProvider.notifier).deleteBudget(widget.categoryId);
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
    ref.read(budgetNotifierProvider.notifier).deleteBudget(widget.categoryId);
    Navigator.of(context).pop();
  }

  String _formatPreset(int amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(0)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final currencySymbol = NumExtension.activeCurrencySymbol;
    final hasAmount = _amountCtrl.text.trim().isNotEmpty &&
        (double.tryParse(_amountCtrl.text) ?? 0) > 0;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Drag handle ──
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Category Header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Icon with subtle glow ring
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: widget.iconBg,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: widget.iconColor.withAlpha(50),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
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
                            'MONTHLY LIMIT',
                            style: styles.caption.copyWith(
                              color: colors.textMuted,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.categoryName,
                            style: styles.heading.copyWith(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.currentLimit > 0)
                      _DeleteButton(colors: colors, onTap: _delete),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Amount input card ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _AmountInputCard(
                  amountCtrl: _amountCtrl,
                  focusNode: _focusNode,
                  currencySymbol: currencySymbol,
                  colors: colors,
                  styles: styles,
                  onChanged: () => setState(() {}),
                  onSubmitted: (_) => _save(),
                ),
              ),

              const SizedBox(height: 16),

              // ── Preset chips ──
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick select',
                      style: styles.caption.copyWith(
                        color: colors.textMuted,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _presets.map((amount) {
                          final isSelected =
                              _amountCtrl.text == amount.toString();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _PresetChip(
                              label:
                                  '$currencySymbol ${_formatPreset(amount)}',
                              isSelected: isSelected,
                              colors: colors,
                              styles: styles,
                              onTap: () => _applyPreset(amount),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Divider ──
              Divider(
                color: colors.divider,
                height: 1,
                indent: 24,
                endIndent: 24,
              ),
              const SizedBox(height: 20),

              // ── Save Button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: _SaveButton(
                  isUpdate: widget.currentLimit > 0,
                  isEnabled: hasAmount,
                  colors: colors,
                  styles: styles,
                  onTap: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────

class _DeleteButton extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onTap;

  const _DeleteButton({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.expenseBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.expenseRed.withAlpha(50),
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: colors.expenseRed,
          size: 18,
        ),
      ),
    );
  }
}

class _AmountInputCard extends StatelessWidget {
  final TextEditingController amountCtrl;
  final FocusNode focusNode;
  final String currencySymbol;
  final AppColors colors;
  final dynamic styles;
  final VoidCallback onChanged;
  final ValueChanged<String> onSubmitted;

  const _AmountInputCard({
    required this.amountCtrl,
    required this.focusNode,
    required this.currencySymbol,
    required this.colors,
    required this.styles,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        // Subtle violet tint background — uses insightBannerBg from color scheme
        color: colors.insightBannerBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.primary.withAlpha(55),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Currency symbol badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primary.withAlpha(18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colors.primary.withAlpha(40),
                width: 0.5,
              ),
            ),
            child: Text(
              currencySymbol,
              style: styles.heading.copyWith(
                fontSize: 16.0,
                color: colors.insightBannerText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Big number field
          IntrinsicWidth(
            child: TextField(
              controller: amountCtrl,
              focusNode: focusNode,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: styles.displayAmount?.copyWith(
                    fontSize: 48.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2.0,
                    color: colors.textPrimary,
                  ) ??
                  TextStyle(
                    fontSize: 48.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2.0,
                    color: colors.textPrimary,
                  ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  fontSize: 48.0,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -2.0,
                  color: colors.textMuted.withAlpha(80),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 100),
              ),
              onChanged: (_) => onChanged(),
              onSubmitted: onSubmitted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'per month',
            style: styles.caption?.copyWith(
                  color: colors.insightBannerText.withAlpha(160),
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                ) ??
                TextStyle(
                  color: colors.insightBannerText.withAlpha(160),
                  fontSize: 13.0,
                ),
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final AppColors colors;
  final dynamic styles;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.isSelected,
    required this.colors,
    required this.styles,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [colors.primary, colors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.divider,
            width: isSelected ? 0 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withAlpha(60),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: styles.label?.copyWith(
                color: isSelected ? Colors.white : colors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13.0,
              ) ??
              TextStyle(
                color: isSelected ? Colors.white : colors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13.0,
              ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isUpdate;
  final bool isEnabled;
  final AppColors colors;
  final dynamic styles;
  final VoidCallback onTap;

  const _SaveButton({
    required this.isUpdate,
    required this.isEnabled,
    required this.colors,
    required this.styles,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isEnabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            gradient: isEnabled
                ? colors.balanceCardGradient
                : null,
            color: isEnabled ? null : colors.surfaceSubtle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: colors.primary.withAlpha(90),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: colors.secondary.withAlpha(50),
                      blurRadius: 10,
                      offset: const Offset(-4, 4),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUpdate
                    ? Icons.edit_rounded
                    : Icons.check_rounded,
                color: isEnabled ? Colors.white : colors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isUpdate ? 'Update Budget' : 'Set Budget',
                style: styles.bodyMedium?.copyWith(
                      color: isEnabled ? Colors.white : colors.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                    ) ??
                    TextStyle(
                      color: isEnabled ? Colors.white : colors.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}