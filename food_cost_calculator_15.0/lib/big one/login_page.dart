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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Image.asset("lib/image/AppIcon-1024.png", width: 200, height: 200),// Replace with your app icon
              Text("매추리R(with AI)", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)), // Add your title
              const SizedBox(height: 50),
              SizedBox(
                width: 250, // 원하는 너비로 변경
                height: 60, // 원하는 높이로 변경
                child: ElevatedButton(
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
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),  // Set background color to white
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.deepPurpleAccent, width: 2.0),  // Increase width to create a thicker border
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.deepPurpleAccent.withOpacity(0.1)),  // Add a overlay color to create a slight hover effect
                  ),
                  child: const Text(
                    'Sign in with Google',
                    style: TextStyle(fontSize: 20.0, color: Colors.deepPurpleAccent),  // Set text color to deepPurpleAccent
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 250, // 원하는 너비로 변경
                height: 60, // 원하는 높이로 변경
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    ref.read(loggedInUserProvider.notifier).state = null;
                    Navigator.pushReplacementNamed(context, '/cost-input');
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),  // Set background color to white
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.deepPurpleAccent, width: 2.0),  // Increase width to create a thicker border
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.deepPurpleAccent.withOpacity(0.1)),  // Add a overlay color to create a slight hover effect
                  ),
                  child: const Text(
                    '로그인 없이 기본기능만',
                    style: TextStyle(fontSize: 20.0, color: Colors.deepPurpleAccent),  // Set text color to deepPurpleAccent
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Card(
                color: Colors.white,
                shape:
                RoundedRectangleBorder(
                  side: BorderSide(color: Colors.deepPurpleAccent),
                ),
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  title: Text(
                    "공지사항",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "버전 15 변경사항: 이제 AI에게 기존에 작성한 보고서에 대한 조언과 분석을 사용자가 직접 질문을 통해 요청할 수 있습니다. \n 질문이 없을 경우 기본적으로 설정된 분석을 제공합니다. \n 앱 아이콘이 생겼습니다. \n 한번 AI에게 답변을 받고 추가적인 대화를 같은 AI와 이어서 나눌 수 있도록 작업 중에 있습니다.(현재 형태만 작성됨.)\n 아직 AI 분석 기능에 제한을 걸어두지 않았으니 많은 사용 부탁드립니다. ",
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



