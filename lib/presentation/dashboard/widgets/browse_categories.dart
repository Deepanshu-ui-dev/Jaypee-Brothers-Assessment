import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/bouncing_button.dart';
import '../../../data/models/category_model.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/transaction_provider.dart';

class BrowseCategories extends ConsumerWidget {
  const BrowseCategories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoriesProvider);

    // Show only expense categories, max 8
    final expenseCats = cats
        .where((c) => c.type == 'expense' || c.type == 'both')
        .take(8)
        .toList();

    if (expenseCats.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: expenseCats.map((cat) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _CategoryCard(
              category: cat,
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(txnCategoryFilterProvider.notifier).state = cat.id;
                ref.read(txnFilterProvider.notifier).state = TxnFilter.expense;
                context.go('/transactions');
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final CategoryModel category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onTap: onTap,
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.divider, width: 0.5),
          boxShadow: context.colors.subtleShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: category.themedBgColor(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              category.name,
              style: context.textStyles.caption.copyWith(
                  fontWeight: FontWeight.w600, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
