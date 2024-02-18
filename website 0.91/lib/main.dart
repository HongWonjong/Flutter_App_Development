import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'page/mainpage.dart'; // 메인 파일의 이름에 따라 수정
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'function/fetch_secret_value.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    String gpt35_key = await fetchGptApiKey();
    String secretValue = await fetchSecretValue();
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider(secretValue),
    );
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(ProviderScope(child: MyApp()));
}

