import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'page/mainpage.dart'; // 메인 파일의 이름에 따라 수정
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized(); // 웹사이트 개발에 필수적인 플러터엔진과 위젯을 바인딩함

  await Firebase.initializeApp( // 파이어베이스 초기화
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Future<String> fetchSecretValue() async { //구글 시크릿 매니저의 리캡쳐 토큰값을 가져올 것이다.
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getSecretValue');
    final response = await callable.call();
    return response.data['secretValue'];
  }
  // 비동기 함수를 사용하여 ReCaptchaV3Provider를 초기화하기
  String secretValue = await fetchSecretValue();
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider(secretValue),
  );

  runApp(
    ProviderScope( // 앱 전체에서 리버팟을 사용할 수 있도록!
      child: MyApp(),
    ),
  );
}