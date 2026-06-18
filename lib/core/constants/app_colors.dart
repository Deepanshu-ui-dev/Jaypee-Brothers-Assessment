import 'package:flutter/material.dart';
export '../extensions/context_extension.dart';

/// All color constants for FinTrack design system.
class AppColors {
  final bool isDark;
  const AppColors(this.isDark);

  // Surfaces
  Color get surface       => isDark ? const Color(0xFF18181B) : const Color(0xFFFFFFFF);
  Color get surfaceSubtle => isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
  Color get pageBg        => isDark ? const Color(0xFF09090B) : const Color(0xFFFAFAFA);
  Color get divider       => isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

  // Text
  Color get textPrimary   => isDark ? const Color(0xFFFAFAFA) : const Color(0xFF18181B);
  Color get textSecondary => isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
  Color get textMuted     => isDark ? const Color(0xFF71717A) : const Color(0xFFA1A1AA);

  // Primary Branding (Electric Violet & Blue)
  Color get primary       => const Color(0xFF7C3AED); // Vibrant Violet
  Color get primaryDark   => const Color(0xFF5B21B6); 
  Color get secondary     => const Color(0xFF3B82F6); // Electric Blue

  // Action / Ink
  Color get ink           => isDark ? const Color(0xFFFAFAFA) : const Color(0xFF18181B);
  Color get onInk         => isDark ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);
  
  // Semantic
  Color get onPrimary     => Colors.white;
  Color get incomeGreen   => const Color(0xFF10B981); // Emerald
  Color get incomeBg      => isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
  Color get expenseRed    => const Color(0xFFF43F5E); // Rose
  Color get expenseBg     => isDark ? const Color(0xFF881337) : const Color(0xFFFFE4E6);

  // Category Base Tints (solid colors)
  Color get categoryFood      => const Color(0xFFF59E0B); // Amber
  Color get categoryTransport => const Color(0xFF3B82F6); // Blue
  Color get categoryGrocery   => const Color(0xFF10B981); // Emerald
  Color get categoryShopping  => const Color(0xFFEC4899); // Pink
  Color get categoryElectricity => const Color(0xFFF43F5E); // Rose
  Color get categoryData      => const Color(0xFF8B5CF6); // Violet
  Color get categoryOthers    => const Color(0xFF64748B); // Slate

  // Feature specific
  Color get balanceCardBg     => const Color(0xFF7C3AED);
  Color get balanceCardText   => Colors.white;
  Color get insightBannerBg   => isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEDE9FE);
  Color get insightBannerText => isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9);

  // Modern UI Glass/Gradients
  Color get surfaceGlass  => isDark ? const Color(0x9918181B) : const Color(0xCCFFFFFF);
  Color get bottomNavGlass => isDark ? const Color(0xE609090B) : const Color(0xF2FFFFFF);
  
  // Premium Glow Shadows
  List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: primary.withAlpha(isDark ? 80 : 100),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: secondary.withAlpha(isDark ? 40 : 60),
      blurRadius: 16,
      offset: const Offset(-8, 8),
    ),
  ];

  List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: isDark ? Colors.black.withAlpha(200) : const Color(0xFF71717A).withAlpha(15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    )
  ];

  LinearGradient get balanceCardGradient => const LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)], // Violet to Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get secondaryGradient => const LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFF97316)], // Rose to Orange
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category background tints (reactive glass-like)
  Color get tintFood       => isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
  Color get tintTransport  => isDark ? const Color(0xFF172554) : const Color(0xFFDBEAFE);
  Color get tintShopping   => isDark ? const Color(0xFF831843) : const Color(0xFFFCE7F3);
  Color get tintElec       => isDark ? const Color(0xFF4C0519) : const Color(0xFFFFE4E6);
  Color get tintData       => isDark ? const Color(0xFF2E1065) : const Color(0xFFF3E8FF);
  Color get tintSoftware   => isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
  Color get tintHealth     => isDark ? const Color(0xFF4C0519) : const Color(0xFFFFE4E6);
  Color get tintEducation  => isDark ? const Color(0xFF172554) : const Color(0xFFDBEAFE);
  Color get tintPink       => isDark ? const Color(0xFF831843) : const Color(0xFFFCE7F3);
  Color get tintPurple     => isDark ? const Color(0xFF2E1065) : const Color(0xFFF3E8FF);
  Color get tintGray       => isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
}
