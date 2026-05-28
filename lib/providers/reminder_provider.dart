import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/notification_service.dart';

class ReminderNotifier extends StateNotifier<bool> {
  ReminderNotifier() : super(false) {
    _load();
  }

  static const _key = 'daily_reminder_enabled';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state;
    await prefs.setBool(_key, newValue);
    if (newValue) {
      await NotificationService.scheduleDailyReminder();
    } else {
      await NotificationService.cancelAll();
    }
    state = newValue;
  }
}

final reminderProvider = StateNotifierProvider<ReminderNotifier, bool>(
  (ref) => ReminderNotifier(),
);
