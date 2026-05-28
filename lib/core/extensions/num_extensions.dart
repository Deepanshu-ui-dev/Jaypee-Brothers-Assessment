import 'package:intl/intl.dart';

extension NumExtension on num {
  /// Formats as currency: ₹1,234.56
  String get asCurrency {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(this);
  }

  /// Compact currency: ₹1.2K, ₹1.5L
  String get compactCurrency {
    if (this >= 100000) {
      return '₹${(this / 100000).toStringAsFixed(1)}L';
    } else if (this >= 1000) {
      return '₹${(this / 1000).toStringAsFixed(1)}K';
    }
    return '₹${toStringAsFixed(0)}';
  }

  /// Formats as percentage: 45.2%
  String get asPercentage => '${toStringAsFixed(1)}%';
}

extension DoubleExtension on double {
  /// Clamps to [0.0, 1.0] for progress bars
  double get clampedProgress => clamp(0.0, 1.0).toDouble();
}
