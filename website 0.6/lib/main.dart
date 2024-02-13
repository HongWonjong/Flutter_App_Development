import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'page/mainpage.dart'; // 메인 파일의 이름에 따라 수정
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase App Check 초기화
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider("6LcJG2kpAAAAAJZMe2b-oth304J4WqmDRFA2dJhp"),
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}