import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  final AppColors colors;
  const AppTextStyles(this.colors);

  TextStyle get displayAmount => GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        height: 1.1,
        color: colors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  TextStyle get displayAmountWhite => GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        height: 1.1,
        color: Colors.white,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  TextStyle get cardAmount => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  TextStyle get cardAmountGreen => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.incomeGreen,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  TextStyle get cardAmountRed => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.expenseRed,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  TextStyle get heading => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: colors.textPrimary,
        letterSpacing: -0.8,
        height: 1.2,
      );

  TextStyle get subheading => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        letterSpacing: -0.3,
        height: 1.3,
      );

  TextStyle get body => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      );

  TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        height: 1.4,
      );

  TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
      );

  TextStyle get label => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colors.textMuted,
      );

  TextStyle get buttonLabel => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: colors.onInk,
      );

  TextStyle get sectionHeader => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colors.textSecondary,
      );

  TextStyle get appBarTitle => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        letterSpacing: -0.5,
      );
}
