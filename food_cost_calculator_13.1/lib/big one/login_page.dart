import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../logic/auth_service.dart';
import '../main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = Provider<AuthService>((ref) => AuthService(ref));

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              ElevatedButton(
                onPressed: () async {
                  if (ref.watch(loggedInUserProvider)?.displayName != null) {
                    Navigator.pushReplacementNamed(context, '/cost-input');
                  } else {
                    UserCredential userCredential = await ref.read(authService).signInWithGoogle();
                    User? user = userCredential.user;
                    if (user != null && user.displayName != null) {
                      ref.read(loggedInUserProvider.notifier).state = user;
                      Navigator.pushReplacementNamed(context, '/cost-input');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                ),
                child: const Text(
                  'Sign in with Google',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  ref.read(loggedInUserProvider.notifier).state = null;
                  Navigator.pushReplacementNamed(context, '/cost-input');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: Colors.deepPurpleAccent),
                  ),
                ),
                child: const Text(
                  '로그인 없이 기본기능만',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.yellow[200],
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: const ListTile(
                  title: Text(
                    "개발자 공지사항",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "버전 13 변경사항: 바 그래프의 금액을 만원 단위로 변경하여 UI 개선, 앱 기능 확장에 따른 도움말 페이지를 메뉴에 추가. \n 보고서 여러개를 체크하여 좌측 하단을 클릭하면 여러 보고서를 연동하여 기간별 매출 관련 정보들을 보여주는 기능 추가.",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



