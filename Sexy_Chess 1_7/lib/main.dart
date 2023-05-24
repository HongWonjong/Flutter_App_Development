import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: "AIzaSyBiD72kJusn0jLNUKG3pW99lVWIR7HG79c");  // replace with your reCAPTCHA site key
  // 이 키는 구글 클라우드 콘솔의 API 및 서비스 => 사용자 인증정보에서 볼 수 있다.

  runApp(const MaterialApp(home: LoginScreen()));
}








