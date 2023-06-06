import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../logic/auth_service.dart';
import '../main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loggedInUserProvider.notifier).state;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                if (user != null) {
                  // 유저가 로그인되어 있는 경우, cost_input 페이지로 이동
                  Navigator.pushReplacementNamed(context, '/cost-input');
                } else {
                  // 유저가 로그인되어 있지 않은 경우, Google 로그인 실행
                  await ref.read(authService).signInWithGoogle();
                  ref.read(loggedInUserProvider.notifier).state =
                      FirebaseAuth.instance.currentUser;
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
              onPressed: () {
                // "그냥 사용하기" 버튼을 누를 때 로그인 없이 cost_input 페이지로 이동
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
                '로그인 없이 사용하기',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


