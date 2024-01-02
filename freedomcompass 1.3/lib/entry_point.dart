import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'page/login_page.dart';
import 'page/main_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:freedomcompass/function/user_repository.dart';
import 'riverpod/user_riverpod.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAppCheck appCheck = FirebaseAppCheck.instance;
  await appCheck.activate();

  runApp(
      ProviderScope(
      child: MyApp()
  ));
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '자유의 나침반',// 앱 아이콘과 이름을 설정
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;



          if (user == null) {
            // 사용자가 로그인되어 있지 않은 경우
            return LoginPage();
          } else {
            // 사용자가 이미 로그인되어 있는 경우
            return MainPage();
          }
        }

        // 연결이 활성화되지 않은 경우 로딩 페이지 또는 다른 처리를 할 수 있습니다.
        return const CircularProgressIndicator();
      },
    );
  }
}
