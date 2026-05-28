import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

extension ThemeContextExtension on BuildContext {
  AppColors get colors => AppColors(Theme.of(this).brightness == Brightness.dark);
  AppTextStyles get textStyles => AppTextStyles(colors);
}
