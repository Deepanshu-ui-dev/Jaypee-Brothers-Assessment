import 'package:intl/intl.dart';

extension NumExtension on num {
  static String activeCurrencySymbol = '₹'; // Default fallback
  static String activeLocale = 'en_IN'; // Default locale
  
  /// Formats as currency: e.g. ₹1,234.56 or ₦1,234.56
  String get asCurrency {
    final formatter = NumberFormat.currency(
      locale: activeLocale,
      symbol: activeCurrencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(this);
  }

  /// Compact currency: ₹1.2K, ₦1.2K
  String get compactCurrency {
    if (this >= 1000000) {
      return '$activeCurrencySymbol${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 100000 && activeLocale == 'en_IN') {
      return '$activeCurrencySymbol${(this / 100000).toStringAsFixed(1)}L';
    } else if (this >= 1000) {
      return '$activeCurrencySymbol${(this / 1000).toStringAsFixed(1)}K';
    }
    return '$activeCurrencySymbol${toStringAsFixed(0)}';
  }

  /// Formats as percentage: 45.2%
  String get asPercentage => '${toStringAsFixed(1)}%';
}

extension DoubleExtension on double {
  /// Clamps to [0.0, 1.0] for progress bars
  double get clampedProgress => clamp(0.0, 1.0).toDouble();
}
