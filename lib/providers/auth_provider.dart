import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/hive_service.dart';
import '../data/models/user_model.dart';

// ── Local Profile Provider ──────────────────────────────────────────────────
final localProfileProvider =
    StateNotifierProvider<LocalProfileNotifier, UserModel?>((ref) {
  return LocalProfileNotifier();
});

class LocalProfileNotifier extends StateNotifier<UserModel?> {
  LocalProfileNotifier() : super(null) {
    _load();
  }

  void _load() {
    final settings = HiveService.settings;
    final name = settings.get('profile_name') as String?;
    if (name != null && name.isNotEmpty) {
      state = UserModel(
        name: name,
        currency: settings.get('profile_currency') as String? ?? 'NGN',
        currencySymbol:
            settings.get('profile_currency_symbol') as String? ?? '₦',
      );
    }
  }

  Future<void> saveProfile({
    required String name,
    String currency = 'NGN',
    String currencySymbol = '₦',
  }) async {
    final settings = HiveService.settings;
    await settings.put('profile_name', name);
    await settings.put('profile_currency', currency);
    await settings.put('profile_currency_symbol', currencySymbol);
    state = UserModel(
        name: name, currency: currency, currencySymbol: currencySymbol);
  }

  Future<void> updateName(String name) async {
    await HiveService.settings.put('profile_name', name);
    state = state?.copyWith(name: name) ??
        UserModel(name: name);
  }

  bool get hasProfile => state != null;
}

// ── Convenience provider ────────────────────────────────────────────────────
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(localProfileProvider);
});

final hasProfileProvider = Provider<bool>((ref) {
  return ref.watch(localProfileProvider) != null;
});
