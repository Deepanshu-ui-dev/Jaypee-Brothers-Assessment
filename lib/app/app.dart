import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../core/extensions/num_extensions.dart';
import 'router.dart';

class FinTrackApp extends ConsumerWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    final user = ref.watch(currentUserProvider);
    if (user != null) {
      NumExtension.activeCurrencySymbol = user.currencySymbol;
      if (user.currency == 'NGN') {
        NumExtension.activeLocale = 'en_NG';
      } else if (user.currency == 'INR') {
        NumExtension.activeLocale = 'en_IN';
      } else if (user.currency == 'USD') {
        NumExtension.activeLocale = 'en_US';
      } else if (user.currency == 'EUR') {
        NumExtension.activeLocale = 'en_US';
      } else if (user.currency == 'GBP') {
        NumExtension.activeLocale = 'en_GB';
      } else {
        NumExtension.activeLocale = 'en_US';
      }
    }

    return MaterialApp.router(
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(isDark: false),
      darkTheme: _buildTheme(isDark: true),
      themeMode: themeMode,
      routerConfig: router,
    );
  }

  static ThemeData _buildTheme({required bool isDark}) {
    final colors = AppColors(isDark);
    final textStyles = AppTextStyles(colors);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: colors.pageBg,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: colors.primary,
              surface: colors.surface,
              onSurface: colors.textPrimary,
              outline: colors.divider,
            )
          : ColorScheme.light(
              primary: colors.primary,
              surface: colors.surface,
              onSurface: colors.textPrimary,
              outline: colors.divider,
            ),
      textTheme: isDark
          ? GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme)
          : GoogleFonts.plusJakartaSansTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textStyles.appBarTitle,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.divider, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 0.5,
        space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.divider, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.divider, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.expenseRed, width: 0.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.expenseRed, width: 1),
        ),
        labelStyle: textStyles.caption,
        hintStyle: textStyles.caption,
        errorStyle: textStyles.caption.copyWith(color: colors.expenseRed),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: colors.ink,
        unselectedItemColor: colors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(double.infinity, 52),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.ink,
        contentTextStyle: textStyles.body.copyWith(
          color: isDark ? Colors.black : Colors.white,
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
