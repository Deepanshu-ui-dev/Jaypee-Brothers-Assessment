import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/services/notification_service.dart';
import 'package:collection/collection.dart';
import '../categories/add_category_sheet.dart';
import '../../core/widgets/bottom_padding.dart';
import '../../core/widgets/bouncing_button.dart';

class AddEditTransactionSheet extends ConsumerStatefulWidget {
  const AddEditTransactionSheet({super.key, this.existing});
  final TransactionModel? existing;

  @override
  ConsumerState<AddEditTransactionSheet> createState() =>
      _AddEditTransactionSheetState();
}

class _AddEditTransactionSheetState
    extends ConsumerState<AddEditTransactionSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _receiptCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  CategoryModel? _selectedCategory;
  DateTime _date = DateTime.now();
  String? _paymentMethod;
  bool _loading = false;

  late AnimationController _typeToggleCtrl;
  late Animation<double> _typeToggleAnim;

  final List<String> _paymentMethods = const [
    'Cash',
    'Credit Card',
    'Debit Card',
    'Bank Transfer',
    'Wallet'
  ];

  @override
  void initState() {
    super.initState();
    _typeToggleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _typeToggleAnim = CurvedAnimation(
      parent: _typeToggleCtrl,
      curve: Curves.easeInOut,
    );

    final e = widget.existing;
    if (e != null) {
      _type = e.type;
      _amountCtrl.text = e.amount.toStringAsFixed(2);
      _noteCtrl.text = e.note;
      _date = e.date;
      _receiptCtrl.text = e.receiptNumber ?? '';
      _paymentMethod = e.paymentMethod;
      if (_type == TransactionType.income) _typeToggleCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _typeToggleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _receiptCtrl.dispose();
    super.dispose();
  }

  void _setType(TransactionType type) {
    if (_type == type) return;
    HapticFeedback.selectionClick();
    setState(() {
      _type = type;
      _selectedCategory = null;
    });
    if (type == TransactionType.income) {
      _typeToggleCtrl.forward();
    } else {
      _typeToggleCtrl.reverse();
    }
  }

  Future<void> _delete() async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Delete', style: TextStyle(color: context.colors.expenseRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _loading = true);
      try {
        await ref.read(transactionNotifierProvider.notifier).delete(widget.existing!.id);
        HapticFeedback.mediumImpact();
        navigator.pop();
      } catch (_) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null && widget.existing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    setState(() => _loading = true);
    final navigator = Navigator.of(context);
    final notifier = ref.read(transactionNotifierProvider.notifier);
    final cat = _selectedCategory;

    final txn = TransactionModel(
      id: widget.existing?.id ?? '',
      type: _type,
      amount: double.parse(_amountCtrl.text.replaceAll(',', '')),
      categoryId: cat?.id ?? widget.existing?.categoryId ?? '',
      categoryName: cat?.name ?? widget.existing?.categoryName ?? 'Other',
      date: _date,
      note: _noteCtrl.text.trim(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      receiptNumber:
          _receiptCtrl.text.trim().isEmpty ? null : _receiptCtrl.text.trim(),
      paymentMethod: _paymentMethod,
    );

    try {
      if (widget.existing != null) {
        await notifier.update(txn);
      } else {
        await notifier.add(txn);
      }
      
      if (txn.isExpense) {
        final alerts = ref.read(budgetAlertsProvider);
        final alert = alerts.firstWhereOrNull((a) => a.categoryId == txn.categoryId);
        if (alert != null) {
          NotificationService.showBudgetAlert(
            'Budget Alert ⚠️', 
            'You have reached ${(alert.pct * 100).toStringAsFixed(0)}% of your ${txn.categoryName} budget!'
          );
        }
      }

      if (mounted) {
        HapticFeedback.mediumImpact();
        navigator.pop();
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).brightness == Brightness.dark
              ? ColorScheme.dark(
                  primary: context.colors.primary,
                  surface: context.colors.surface)
              : ColorScheme.light(primary: context.colors.primary),
        ),
        child: child!,
      ),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_date),
      );
      if (pickedTime != null) {
        if (!mounted) return;
        setState(() {
          _date = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
              pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  void _showCategoryPicker(BuildContext context, List<CategoryModel> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Category',
                style: context.textStyles.subheading.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, __) => Divider(height: 1, color: context.colors.divider),
                  itemBuilder: (context, index) {
                    if (index == categories.length) {
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add_rounded, color: context.colors.primary),
                        ),
                        title: Text(
                          'Create Custom Category',
                          style: context.textStyles.bodyMedium.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Icon(Icons.chevron_right_rounded, color: context.colors.textSecondary),
                        onTap: () {
                          Navigator.pop(context);
                          _showAddCategorySheet();
                        },
                      );
                    }
                    final cat = categories[index];
                    final isSelected = _selectedCategory?.id == cat.id;
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cat.themedBgColor(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(cat.icon, color: cat.color, size: 20),
                      ),
                      title: Text(cat.name, style: context.textStyles.bodyMedium),
                      trailing: isSelected 
                          ? Icon(Icons.check_rounded, color: context.colors.primary, size: 22) 
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentMethodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Payment Method',
                style: context.textStyles.subheading.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _paymentMethods.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: context.colors.divider),
                  itemBuilder: (context, index) {
                    final method = _paymentMethods[index];
                    final isSelected = _paymentMethod == method;
                    return ListTile(
                      leading: Icon(
                        _getPaymentMethodIcon(method),
                        color: isSelected ? context.colors.primary : context.colors.textSecondary,
                      ),
                      title: Text(method, style: context.textStyles.bodyMedium),
                      trailing: isSelected 
                          ? Icon(Icons.check_rounded, color: context.colors.primary, size: 22) 
                          : null,
                      onTap: () {
                        setState(() {
                          _paymentMethod = method;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money_rounded;
      case 'credit card':
      case 'debit card':
        return Icons.credit_card_rounded;
      case 'bank transfer':
        return Icons.account_balance_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  void _showAddCategorySheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => AddCategorySheet(
          type: _type == TransactionType.expense ? 'expense' : 'income'),
    );
  }

  Widget _buildFormRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: context.colors.subtleShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: context.textStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const Spacer(),
              trailing,
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: context.colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String hintText,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.colors.subtleShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: context.textStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller,
                textAlign: TextAlign.end,
                style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: context.textStyles.bodyMedium.copyWith(
                    color: context.colors.textMuted,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: context.colors.divider,
      indent: 52,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _type == TransactionType.income;
    final accentColor =
        isIncome ? context.colors.incomeGreen : context.colors.expenseRed;

    final categories = ref.watch(
        _type == TransactionType.expense
            ? expenseCategoriesProvider
            : incomeCategoriesProvider);

    if (_selectedCategory == null && widget.existing != null) {
      final catList = categories;
      try {
        _selectedCategory =
            catList.firstWhere((c) => c.id == widget.existing!.categoryId);
      } catch (_) {}
    }

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.pageBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                          color: context.colors.divider,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Top Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: context.colors.textSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          'Cancel',
                          style: context.textStyles.bodyMedium.copyWith(
                            color: context.colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        widget.existing != null ? 'Edit Transaction' : 'New Transaction',
                        style: context.textStyles.heading.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (widget.existing != null)
                        TextButton(
                          onPressed: _delete,
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.expenseRed,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Delete',
                            style: context.textStyles.bodyMedium.copyWith(
                              color: context.colors.expenseRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        const Opacity(
                          opacity: 0,
                          child: TextButton(
                            onPressed: null,
                            child: Text('Delete'),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Amount Input (Borderless, Huge) ─────────────────────────
                  Center(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _amountCtrl,
                          autofocus: widget.existing == null,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: context.textStyles.displayAmount.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                            letterSpacing: -1.0,
                          ),
                          validator: Validators.amount,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: '₹0.00',
                            hintStyle: TextStyle(
                              color: accentColor.withAlpha(80),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'TAP TO ENTER AMOUNT',
                          style: context.textStyles.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: context.colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Type Toggle ─────────────────────────────────────────────
                  Center(
                    child: Container(
                      height: 38,
                      width: 200,
                      decoration: BoxDecoration(
                        color: context.colors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Stack(
                        children: [
                          // Animated sliding indicator
                          AnimatedBuilder(
                            animation: _typeToggleAnim,
                            builder: (context, _) {
                              return Align(
                                alignment: Alignment.lerp(
                                    Alignment.centerLeft,
                                    Alignment.centerRight,
                                    _typeToggleAnim.value)!,
                                child: FractionallySizedBox(
                                  widthFactor: 0.5,
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: isIncome
                                          ? context.colors.incomeGreen
                                          : context.colors.expenseRed,
                                      borderRadius: BorderRadius.circular(17),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentColor.withAlpha(40),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Labels
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _setType(TransactionType.expense),
                                  child: Container(
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: context.textStyles.bodyMedium.copyWith(
                                        color: !isIncome
                                            ? Colors.white
                                            : context.colors.textSecondary,
                                        fontWeight: !isIncome
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                      child: const Text('Expense'),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _setType(TransactionType.income),
                                  child: Container(
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: context.textStyles.bodyMedium.copyWith(
                                        color: isIncome
                                            ? Colors.white
                                            : context.colors.textSecondary,
                                        fontWeight: isIncome
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                      child: const Text('Income'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Form Cards ─────────────────────────────────
                  Column(
                    children: [
                      // Category Selection Row
                      _buildFormRow(
                        icon: Icons.grid_view_rounded,
                        iconColor: context.colors.primary,
                        title: 'Category',
                        trailing: _selectedCategory != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: _selectedCategory!.themedBgColor(context),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _selectedCategory!.icon,
                                      color: _selectedCategory!.color,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedCategory!.name,
                                    style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            : Text(
                                'Select Category',
                                style: context.textStyles.bodyMedium.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                        onTap: () => _showCategoryPicker(context, categories),
                      ),

                      // Date Selection Row
                      _buildFormRow(
                        icon: Icons.calendar_today_rounded,
                        iconColor: Colors.orange,
                        title: 'Date',
                        trailing: Text(
                          DateFormat("MMM d, yyyy 'at' h:mm a").format(_date),
                          style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        onTap: _pickDate,
                      ),

                      // Payment Method Row
                      _buildFormRow(
                        icon: Icons.credit_card_rounded,
                        iconColor: Colors.blue,
                        title: 'Payment',
                        trailing: Text(
                          _paymentMethod ?? 'Select Method',
                          style: context.textStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _paymentMethod == null ? context.colors.textSecondary : null,
                          ),
                        ),
                        onTap: () => _showPaymentMethodPicker(context),
                      ),

                      // Note Input Row
                      _buildInputRow(
                        icon: Icons.edit_note_rounded,
                        iconColor: Colors.teal,
                        title: 'Note',
                        hintText: 'What was this for?',
                        controller: _noteCtrl,
                      ),

                      // Receipt Number Row
                      _buildInputRow(
                        icon: Icons.receipt_long_rounded,
                        iconColor: Colors.purple,
                        title: 'Receipt',
                        hintText: 'Optional number',
                        controller: _receiptCtrl,
                      ),
                    ],
                  ),

                  // Budget Alert Banner
                  if (_selectedCategory != null) ...[
                    const SizedBox(height: 16),
                    Consumer(
                      builder: (context, ref, child) {
                        final amt = double.tryParse(_amountCtrl.text) ?? 0.0;
                        final proj = ref.watch(projectedBudgetPctProvider(
                            (categoryId: _selectedCategory!.id, newAmount: amt)));
                        if (proj == null) return const SizedBox.shrink();

                        final isWarning = proj >= 1.0;
                        final pctText = (proj * 100).toInt();

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isWarning
                                ? context.colors.expenseRed.withAlpha(15)
                                : context.colors.primary.withAlpha(15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isWarning
                                  ? context.colors.expenseRed.withAlpha(30)
                                  : context.colors.primary.withAlpha(30),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isWarning ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                                color: isWarning ? context.colors.expenseRed : context.colors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isWarning
                                      ? 'This exceeds your ${_selectedCategory!.name} budget'
                                      : 'You are at $pctText% of the ${_selectedCategory!.name} budget',
                                  style: context.textStyles.caption.copyWith(
                                    color: isWarning ? context.colors.expenseRed : context.colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 28),

                  // ── Save Button ────────────────────────────────────────────
                  BouncingButton(
                    onTap: _loading ? () {} : _save,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: isIncome
                            ? LinearGradient(
                                colors: [accentColor, accentColor.withAlpha(200)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : context.colors.balanceCardGradient,
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                            color: (isIncome ? accentColor : context.colors.primary).withAlpha(80),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          if (!isIncome)
                            BoxShadow(
                              color: context.colors.secondary.withAlpha(50),
                              blurRadius: 10,
                              offset: const Offset(-4, 4),
                            ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isIncome
                                      ? Icons.add_circle_outline_rounded
                                      : Icons.check_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.existing != null
                                      ? 'Update Transaction'
                                      : isIncome
                                          ? 'Save Income'
                                          : 'Save Expense',
                                  style: context.textStyles.buttonLabel.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const BottomPadding(minimum: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
