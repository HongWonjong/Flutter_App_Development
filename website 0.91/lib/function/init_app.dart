import 'package:firebase_core/firebase_core.dart';
import '/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'fetch_secret_value.dart';
import 'package:dart_openai/dart_openai.dart';
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

    // OpenAI API 키 설정
    try {
      OpenAI.apiKey = await fetchGpt35ApiKey();
      OpenAI.showLogs = true; //문제 생기면 로그 뜨게 함
    } catch (e) {
      print("OpenAI API key configuration error: $e");
    }

    // Firebase App Check 활성화
    try {
      String secretValue = await fetchRecaptchaToken();
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider(secretValue),
      );
    } catch (e) {
      print("Firebase App Check activation error: $e");
    }
  }
}
