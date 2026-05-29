import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseService {
  static Future<void> initialize() async {
    try {
      final apiKey = dotenv.env['FIREBASE_API_KEY'];
      final appId = dotenv.env['FIREBASE_APP_ID'];
      final messagingSenderId = dotenv.env['FIREBASE_MESSAGING_SENDER_ID'];
      final projectId = dotenv.env['FIREBASE_PROJECT_ID'];
      final authDomain = dotenv.env['FIREBASE_AUTH_DOMAIN'];
      final storageBucket = dotenv.env['FIREBASE_STORAGE_BUCKET'];

      if (apiKey != null && apiKey.isNotEmpty && apiKey != 'your_api_key_here') {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: apiKey,
            appId: appId ?? '',
            messagingSenderId: messagingSenderId ?? '',
            projectId: projectId ?? '',
            authDomain: authDomain,
            storageBucket: storageBucket,
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
    } catch (e) {
      // Fallback if options are not supported or environment is missing
      await Firebase.initializeApp();
    }

    // Enable Firestore offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
