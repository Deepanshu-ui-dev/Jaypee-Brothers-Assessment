import 'package:flutter/material.dart';
export '../extensions/context_extension.dart';

/// All color constants for FinTrack design system.
class AppColors {
  final bool isDark;
  const AppColors(this.isDark);

  // Surfaces
  Color get surface       => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  Color get surfaceSubtle => isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);
  Color get pageBg        => isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
  Color get divider       => isDark ? const Color(0xFF333333) : const Color(0xFFEAEAEA);

  // Text
  Color get textPrimary   => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1E2430);
  Color get textSecondary => isDark ? const Color(0xFFA1A1AA) : const Color(0xFF6B7280);
  Color get textMuted     => isDark ? const Color(0xFF71717A) : const Color(0xFF9CA3AF);

  // Primary Branding
  Color get primary       => const Color(0xFF0CA75B); // The vibrant emerald green
  Color get primaryDark   => const Color(0xFF0A8548); // Slightly darker green

  // Action / Ink
  Color get ink           => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1E2430);
  Color get onInk         => isDark ? const Color(0xFF1E2430) : const Color(0xFFFFFFFF);
  
  // Semantic
  Color get onPrimary     => Colors.white;
  Color get incomeGreen   => const Color(0xFF0CA75B);
  Color get incomeBg      => isDark ? const Color(0xFF05381E) : const Color(0xFFE6F6ED);
  Color get expenseRed    => const Color(0xFFFF5656);
  Color get expenseBg     => isDark ? const Color(0xFF4A1818) : const Color(0xFFFFEFEF);

  // Category Tints
  Color get categoryFood      => const Color(0xFF0CA75B);
  Color get categoryTransport => const Color(0xFF3B6BE4);
  Color get categoryGrocery   => const Color(0xFFFF7E3E);
  Color get categoryShopping  => const Color(0xFFF4A100);
  Color get categoryElectricity => const Color(0xFFF04F4F);
  Color get categoryData      => const Color(0xFFB13BE4);
  Color get categoryOthers    => const Color(0xFF677B92);

  // Feature specific
  Color get balanceCardBg     => const Color(0xFF0CA75B);
  Color get balanceCardText   => Colors.white;
  Color get insightBannerBg   => isDark ? const Color(0xFF05381E) : const Color(0xFFEBF6F0);
  Color get insightBannerText => isDark ? const Color(0xFF55C78A) : const Color(0xFF1D784A);

  // Modern UI Glass/Gradients
  Color get surfaceGlass  => isDark ? const Color(0xCC1E1E1E) : const Color(0xCCFFFFFF);
  LinearGradient get balanceCardGradient => const LinearGradient(
    colors: [Color(0xFF0CA75B), Color(0xFF088C4B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category background tints (reactive)
  Color get tintFood       => isDark ? const Color(0xFF052B18) : const Color(0xFFE6F6ED);
  Color get tintTransport  => isDark ? const Color(0xFF14244F) : const Color(0xFFE8EDFB);
  Color get tintShopping   => isDark ? const Color(0xFF473311) : const Color(0xFFFFF4E3);
  Color get tintElec       => isDark ? const Color(0xFF4A1818) : const Color(0xFFFFECEC);
  Color get tintData       => isDark ? const Color(0xFF2D144F) : const Color(0xFFF3E8FB);
  Color get tintSoftware   => isDark ? const Color(0xFF474111) : const Color(0xFFFFF8E1);
  Color get tintHealth     => isDark ? const Color(0xFF4A2518) : const Color(0xFFFFECE5);
  Color get tintEducation  => isDark ? const Color(0xFF14244F) : const Color(0xFFE8EDFB);
  Color get tintPink       => isDark ? const Color(0xFF4A1838) : const Color(0xFFFCE8F3);
  Color get tintPurple     => isDark ? const Color(0xFF2D144F) : const Color(0xFFF0E8FB);
  Color get tintGray       => isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);
}
