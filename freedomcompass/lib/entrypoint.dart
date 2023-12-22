import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'page/loginpage.dart';
import 'page/mainpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data as User?;

          if (user == null) {
            // 사용자가 로그인되어 있지 않은 경우
            return LoginPage();
          } else {
            // 사용자가 이미 로그인되어 있는 경우
            return MainPage();
          }
        }

        // 연결이 활성화되지 않은 경우 로딩 페이지 또는 다른 처리를 할 수 있습니다.
        return CircularProgressIndicator();
      },
    );
  }
}
