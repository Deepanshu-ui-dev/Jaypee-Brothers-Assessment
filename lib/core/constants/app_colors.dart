import 'package:flutter/material.dart';
export '../extensions/context_extension.dart';
export 'app_text_styles.dart';

class AppColors {
  final bool isDark;
  const AppColors(this.isDark);

  Color get pageBg => isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
  Color get surface => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  Color get surfaceSubtle => isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F3F5);
  Color get surfaceGlass => isDark ? const Color(0xFF1E1E1E).withValues(alpha: 0.8) : const Color(0xFFFFFFFF).withValues(alpha: 0.8);

  Color get primary => const Color(0xFF6366F1); // Indigo 500
  Color get primaryDark => const Color(0xFF4F46E5); // Indigo 600
  Color get secondary => const Color(0xFF14B8A6); // Teal

  Color get textPrimary => isDark ? const Color(0xFFF8F9FA) : const Color(0xFF212529);
  Color get textSecondary => isDark ? const Color(0xFFCED4DA) : const Color(0xFF495057);
  Color get textMuted => isDark ? const Color(0xFF6C757D) : const Color(0xFFADB5BD);

  Color get divider => isDark ? const Color(0xFF343A40) : const Color(0xFFDEE2E6);

  Color get incomeGreen => const Color(0xFF10B981);
  Color get expenseRed => const Color(0xFFEF4444);
  
  Color get incomeBg => isDark ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFF10B981).withValues(alpha: 0.1);
  Color get expenseBg => isDark ? const Color(0xFFEF4444).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1);

  Color get ink => isDark ? const Color(0xFFF8F9FA) : const Color(0xFF212529);
  Color get onInk => isDark ? const Color(0xFF212529) : const Color(0xFFF8F9FA);

  // Category Tints
  Color get tintFood => const Color(0xFFF97316);
  Color get tintTransport => const Color(0xFF3B82F6);
  Color get tintShopping => const Color(0xFFEAB308);
  Color get tintPurple => const Color(0xFFA855F7);
  Color get tintHealth => const Color(0xFFEF4444);
  Color get tintEducation => const Color(0xFF8B5CF6);
  Color get tintSoftware => const Color(0xFF06B6D4);
  Color get tintGray => const Color(0xFF6B7280);
  Color get tintPink => const Color(0xFFEC4899);

  // Category Colors
  Color get categoryShopping => const Color(0xFFEAB308);
  Color get categoryData => const Color(0xFF3B82F6);
  Color get categoryFood => const Color(0xFFF97316);
  Color get categoryTransport => const Color(0xFF3B82F6);
  Color get categoryGrocery => const Color(0xFF22C55E);
  Color get categoryOthers => const Color(0xFF6B7280);

  // Insights
  Color get insightBannerBg => isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
  Color get insightBannerText => isDark ? const Color(0xFFDBEAFE) : const Color(0xFF1E3A8A);

  LinearGradient get balanceCardGradient => const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ];

  List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        )
      ];
}
