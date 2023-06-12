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
              const SizedBox(height: 20),
              const Text(
                '음식 원가율 계산기',
                style: TextStyle(
                  fontSize: 40.0,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
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
                  '로그인 없이 기본기능만 쓸래',
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
                    "버전 12 변경사항: \n 작성한 계산 사항을 보고서로 저장하여, 다양한 그래프와 함께 더 유용하게 이용하실 수 있습니다. \n \n 추가 예정 기능: 기존 보고서를 불러와 새 보고서를 작성하는 기능, 보고서 여러개를 묶어서 볼 경우 시간의 흐름을 고려한 추가적인 그래프 및 분석기능 구현, 앱 기능 추가에 따른 도움말 추가 \n\n 위의 기능들을 추가한 후엔, 보고서를 AI에게 전달하여 조언을 받을 수 있도록 GPT 이용 기능을 예정입니다. \n \n 그 외 필요한 부분이 있으시면 개발자 이메일로 보내주세요.",
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



