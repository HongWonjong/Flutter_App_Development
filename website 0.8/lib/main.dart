import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'page/mainpage.dart'; // 메인 파일의 이름에 따라 수정
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized(); // 웹사이트 개발에 필수적인 플러터엔진과 위젯을 바인딩함
  await dotenv.load(fileName: ".env"); // 환경변수 불러오기

  await Firebase.initializeApp( // 파이어베이스 초기화
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase App Check 초기화
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider(dotenv.env['RECAPTCHA_TOKEN']!),
  );

  runApp(
    ProviderScope( // 앱 전체에서 리버팟을 사용할 수 있도록!
      child: MyApp(),
    ),
  );
}