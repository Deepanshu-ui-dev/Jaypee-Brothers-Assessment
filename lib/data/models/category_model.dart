import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_colors.dart';

part 'category_model.g.dart';

@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int iconCodePoint;

  @HiveField(3)
  late String iconFontFamily;

  @HiveField(4)
  late int colorValue;

  @HiveField(5)
  late int bgColorValue;

  @HiveField(6)
  late String type;

  @HiveField(7)
  late bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required this.type,
    this.isDefault = false,
  })  : iconCodePoint = icon.codePoint,
        iconFontFamily = icon.fontFamily ?? 'MaterialIcons',
        colorValue = color.toARGB32(),
        bgColorValue = bgColor.toARGB32();

  CategoryModel.raw({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.colorValue,
    required this.bgColorValue,
    required this.type,
    required this.isDefault,
  });

  /// Resolves icon from a compile-time constant map to satisfy tree-shaking.
  // In CategoryModel class — replace the icon getter
IconData get icon => _kIconMap[iconCodePoint] ?? Icons.category_rounded;

  Color get color => Color(colorValue);
  Color get bgColor => Color(bgColorValue);
}

/// All icon codepoints used across default + any user-created categories.
/// Add new icons here whenever you add them to the app.
const Map<int, IconData> _kIconMap = {
  // Expense defaults
  0xe56c: Icons.restaurant_rounded,
  0xe1b0: Icons.directions_car_rounded,
  0xe549: Icons.shopping_bag_rounded,
  0xe40a: Icons.movie_rounded,
  0xe25a: Icons.favorite_rounded,
  0xe559: Icons.school_rounded,
  0xe1af: Icons.bolt_rounded,
  0xe318: Icons.home_rounded,
  0xe5c8: Icons.spa_rounded,
  0xe5d3: Icons.more_horiz_rounded,
  // Income defaults
  0xe150: Icons.account_balance_wallet_rounded,
  0xe38e: Icons.laptop_rounded,
  0xe6e1: Icons.trending_up_rounded,
  0xe1bc: Icons.card_giftcard_rounded,
  0xe5d5: Icons.refresh_rounded,
  // Common extras — add more as needed
  0xe047: Icons.add_rounded,
  0xe8b8: Icons.settings_rounded,
  0xe7fd: Icons.person_rounded,
  0xe0be: Icons.phone_rounded,
  0xe158: Icons.attach_money_rounded,
  0xe263: Icons.flight_rounded,
  0xe532: Icons.local_hospital_rounded,
  0xe54f: Icons.receipt_rounded,
  0xe57c: Icons.savings_rounded,
  0xe19c: Icons.coffee_rounded,
  0xe3ab: Icons.local_pizza_rounded,
  0xe531: Icons.local_grocery_store_rounded,
  0xe1c4: Icons.child_care_rounded,
  0xe30a: Icons.fitness_center_rounded,
  0xe412: Icons.nature_rounded,
  0xe42d: Icons.pets_rounded,
  0xe558: Icons.subscriptions_rounded,
};

// ─── Default Categories ──────────────────────────────────────────────────────

final List<CategoryModel> kDefaultExpenseCategories = [
  CategoryModel(
    id: 'food',
    name: 'Food & Dining',
    icon: Icons.restaurant_rounded,
    color: const Color(0xFF1A7A4A),
    bgColor: const Color(0xFFE6F6ED),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'transport',
    name: 'Transport',
    icon: Icons.directions_car_rounded,
    color: const Color(0xFF2A4DB3),
    bgColor: const Color(0xFFE8EDFB),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'shopping',
    name: 'Shopping',
    icon: Icons.shopping_bag_rounded,
    color: const Color(0xFFB33A3A),
    bgColor: const Color(0xFFFFF4E3),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'entertainment',
    name: 'Entertainment',
    icon: Icons.movie_rounded,
    color: const Color(0xFF6B2AB3),
    bgColor: const Color(0xFFF0E8FB),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'health',
    name: 'Health',
    icon: Icons.favorite_rounded,
    color: const Color(0xFF993C1D),
    bgColor: const Color(0xFFFFECE5),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'education',
    name: 'Education',
    icon: Icons.school_rounded,
    color: const Color(0xFF2A4DB3),
    bgColor: const Color(0xFFE8EDFB),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'utilities',
    name: 'Utilities',
    icon: Icons.bolt_rounded,
    color: const Color(0xFF996B00),
    bgColor: const Color(0xFFFFF8E1),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'rent',
    name: 'Rent',
    icon: Icons.home_rounded,
    color: const Color(0xFF555555),
    bgColor: const Color(0xFFF0F0F0),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'personal_care',
    name: 'Personal Care',
    icon: Icons.spa_rounded,
    color: const Color(0xFFB32A6B),
    bgColor: const Color(0xFFFCE8F3),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'other_expense',
    name: 'Other',
    icon: Icons.more_horiz_rounded,
    color: const Color(0xFF555555),
    bgColor: const Color(0xFFF0F0F0),
    type: 'expense',
    isDefault: true,
  ),
];

final List<CategoryModel> kDefaultIncomeCategories = [
  CategoryModel(
    id: 'salary',
    name: 'Salary',
    icon: Icons.account_balance_wallet_rounded,
    color: const Color(0xFF1A7A4A),
    bgColor: const Color(0xFFE6F6ED),
    type: 'income',
    isDefault: true,
  ),
  CategoryModel(
    id: 'freelance',
    name: 'Freelance',
    icon: Icons.laptop_rounded,
    color: const Color(0xFF2A4DB3),
    bgColor: const Color(0xFFE8EDFB),
    type: 'income',
    isDefault: true,
  ),
  CategoryModel(
    id: 'investment',
    name: 'Investment',
    icon: Icons.trending_up_rounded,
    color: const Color(0xFF996B00),
    bgColor: const Color(0xFFFFF8E1),
    type: 'income',
    isDefault: true,
  ),
  CategoryModel(
    id: 'gift',
    name: 'Gift',
    icon: Icons.card_giftcard_rounded,
    color: const Color(0xFFB32A6B),
    bgColor: const Color(0xFFFCE8F3),
    type: 'income',
    isDefault: true,
  ),
  CategoryModel(
    id: 'refund',
    name: 'Refund',
    icon: Icons.refresh_rounded,
    color: const Color(0xFF993C1D),
    bgColor: const Color(0xFFFFECE5),
    type: 'income',
    isDefault: true,
  ),
  CategoryModel(
    id: 'other_income',
    name: 'Other',
    icon: Icons.more_horiz_rounded,
    color: const Color(0xFF555555),
    bgColor: const Color(0xFFF0F0F0),
    type: 'income',
    isDefault: true,
  ),
];

List<CategoryModel> get kAllDefaultCategories =>
    [...kDefaultExpenseCategories, ...kDefaultIncomeCategories];

extension CategoryModelX on CategoryModel {
  Color themedBgColor(BuildContext context) {
    if (!isDefault) return bgColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);

    switch (id) {
      case 'food':          return colors.tintFood;
      case 'salary':        return colors.tintFood;
      case 'transport':     return colors.tintTransport;
      case 'freelance':     return colors.tintTransport;
      case 'shopping':      return colors.tintShopping;
      case 'entertainment': return colors.tintPurple;
      case 'health':        return colors.tintHealth;
      case 'refund':        return colors.tintHealth;
      case 'education':     return colors.tintEducation;
      case 'utilities':     return colors.tintSoftware;
      case 'investment':    return colors.tintSoftware;
      case 'rent':          return colors.tintGray;
      case 'personal_care': return colors.tintPink;
      case 'gift':          return colors.tintPink;
      case 'other_expense': return colors.tintGray;
      case 'other_income':  return colors.tintGray;
      default:              return bgColor;
    }
  }
}