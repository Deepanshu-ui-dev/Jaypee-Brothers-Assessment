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
  late String type; // 'expense' | 'income' | 'both'

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
        colorValue = color.value,
        bgColorValue = bgColor.value;

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

  IconData get icon => IconData(iconCodePoint, fontFamily: iconFontFamily);
  Color get color => Color(colorValue);
  Color get bgColor => Color(bgColorValue);
}

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
      case 'food': return colors.tintFood;
      case 'salary': return colors.tintFood;
      case 'transport': return colors.tintTransport;
      case 'freelance': return colors.tintTransport;
      case 'shopping': return colors.tintShopping;
      case 'entertainment': return colors.tintPurple;
      case 'health': return colors.tintHealth;
      case 'refund': return colors.tintHealth;
      case 'education': return colors.tintEducation;
      case 'utilities': return colors.tintSoftware;
      case 'investment': return colors.tintSoftware;
      case 'rent': return colors.tintGray;
      case 'personal_care': return colors.tintPink;
      case 'gift': return colors.tintPink;
      case 'other_expense': return colors.tintGray;
      case 'other_income': return colors.tintGray;
      default: return bgColor;
    }
  }
}
