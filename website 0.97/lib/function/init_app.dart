import 'package:firebase_core/firebase_core.dart';
import '/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';

class AppInitializer {
  static Future<void> initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Firebase 초기화
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      print("Firebase initialization error: $e");
    }


    // Firebase App Check 활성화
    try {
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider("6LcJG2kpAAAAAJZMe2b-oth304J4WqmDRFA2dJhp"),
      );
    } catch (e) {
      print("Firebase App Check activation error: $e");
    }
  }
}
