import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// Returns "Today", "Yesterday", or a formatted date like "Mon, 26 May"
  String get groupLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(year, month, day);

    if (dateOnly == today) return 'TODAY';
    if (dateOnly == yesterday) return 'YESTERDAY';
    return DateFormat('EEE, d MMM').format(this);
  }

  /// Returns "26 May 2024"
  String get longDate => DateFormat('d MMM yyyy').format(this);

  /// Returns "May 2024"
  String get monthYear => DateFormat('MMMM yyyy').format(this);

  /// Returns short month like "Jan", "Feb"
  String get shortMonth => DateFormat('MMM').format(this);

  /// Returns "Mon, 26 May 2024"
  String get fullDate => DateFormat('EEE, d MMM yyyy').format(this);

  /// Returns "26 May"
  String get shortDate => DateFormat('d MMM').format(this);

  /// Returns date-only key for grouping
  DateTime get dateOnly => DateTime(year, month, day);

  /// Returns true if same calendar day as [other]
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
