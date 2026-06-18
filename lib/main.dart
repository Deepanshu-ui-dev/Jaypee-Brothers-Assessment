import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/local/hive_service.dart';
import 'data/services/notification_service.dart';
import 'app/app.dart';

Future<void> main() async {
  print('🚀 [FinTrack] Starting app...');
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('📦 [FinTrack] Initializing Hive...');
    await HiveService.init();

    print('🔔 [FinTrack] Initializing Notifications...');
    await NotificationService.init();

    print('🎬 [FinTrack] Running App...');
    runApp(
      const ProviderScope(
        child: FinTrackApp(),
      ),
    );
  } catch (e, stack) {
    print('❌ [FinTrack] FATAL STARTUP ERROR: $e');
    print(stack);
  }
}
