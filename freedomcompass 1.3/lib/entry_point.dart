import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'page/login_page.dart';
import 'page/main_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:freedomcompass/function/user_repository.dart';
import 'firebase_options.dart';
import 'rriverpod/user_riverpod.dart'; // user_riverpod.dart를 import합니다.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '자유의 나침반',
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
            return LoginPage();
          } else {
            // MainPage에서 user_riverpod.dart에서 가져온 프로바이더 사용
            return MainPage();
          }
        }

        return const CircularProgressIndicator();
      },
    );
  }
}

