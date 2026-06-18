import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/category_model.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/transaction_provider.dart';

class FilterChipsBar extends ConsumerWidget {
  const FilterChipsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(txnFilterProvider);
    final categoryFilter = ref.watch(txnCategoryFilterProvider);
    final categories = ref.watch(categoriesProvider);

    final selectedCategory = categoryFilter != null
        ? categories.cast<CategoryModel?>().firstWhere(
            (c) => c?.id == categoryFilter,
            orElse: () => null)
        : null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Chip(
            label: 'All',
            isSelected: filter == TxnFilter.all,
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(txnFilterProvider.notifier).state = TxnFilter.all;
            },
          ),
          const SizedBox(width: 6),
          _Chip(
            label: 'Income',
            isSelected: filter == TxnFilter.income,
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(txnFilterProvider.notifier).state = TxnFilter.income;
            },
          ),
          const SizedBox(width: 6),
          _Chip(
            label: 'Expense',
            isSelected: filter == TxnFilter.expense,
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(txnFilterProvider.notifier).state = TxnFilter.expense;
            },
          ),
          if (selectedCategory != null) ...[
            const SizedBox(width: 6),
            _CategoryFilterChip(
              category: selectedCategory,
              onClear: () {
                HapticFeedback.selectionClick();
                ref.read(txnCategoryFilterProvider.notifier).state = null;
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.ink : context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.colors.ink : context.colors.divider.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: context.textStyles.label.copyWith(
            color: isSelected ? context.colors.onInk : context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.category,
    required this.onClear,
  });

  final CategoryModel category;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
      decoration: BoxDecoration(
        color: category.themedBgColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: category.color.withAlpha(80),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 14, color: category.color),
          const SizedBox(width: 6),
          Text(
            category.name,
            style: context.textStyles.label.copyWith(
              color: category.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: category.color.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 10,
                color: category.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
