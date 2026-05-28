import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class BiometricState {
  final bool isEnabled;
  final bool isAvailable;
  const BiometricState({this.isEnabled = false, this.isAvailable = false});
  BiometricState copyWith({bool? isEnabled, bool? isAvailable}) {
    return BiometricState(
      isEnabled: isEnabled ?? this.isEnabled,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class BiometricNotifier extends StateNotifier<BiometricState> {
  BiometricNotifier() : super(const BiometricState()) {
    _load();
  }

  static const _key = 'biometric_enabled';
  final _auth = LocalAuthentication();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final available = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    final enabled = prefs.getBool(_key) ?? false;
    state = BiometricState(isEnabled: enabled && available, isAvailable: available);
  }

  Future<bool> toggle() async {
    if (!state.isAvailable) return false;

    if (!state.isEnabled) {
      // Prompt auth before enabling
      final authenticated = await _auth.authenticate(
        localizedReason: 'Enable biometric lock for FinTrack',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      if (!authenticated) return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.isEnabled;
    await prefs.setBool(_key, newValue);
    state = state.copyWith(isEnabled: newValue);
    return true;
  }

  /// Call this on app startup to gate access behind biometrics if enabled.
  Future<bool> authenticate() async {
    if (!state.isEnabled) return true;
    return _auth.authenticate(
      localizedReason: 'Verify your identity to access FinTrack',
      options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final biometricProvider =
    StateNotifierProvider<BiometricNotifier, BiometricState>(
  (ref) => BiometricNotifier(),
);
