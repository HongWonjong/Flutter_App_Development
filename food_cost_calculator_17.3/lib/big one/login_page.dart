import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../logic/auth_service.dart';
import 'package:food_cost_calculator_3_0/logic/user_riverpod.dart';
import 'package:food_cost_calculator_3_0/logic/upload_user_basic_data.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    AuthFunctions authFunctions = AuthFunctions();
    final isLoggedIn = authState.maybeWhen(
      data: (user) => user != null, // User 객체가 null이 아니면 로그인한 것으로 간주
      orElse: () => false, // 그 외의 경우에는 로그인하지 않은 것으로 간주
    );


    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Image.asset("lib/image/AppIcon-1024.png", width: 200, height: 200),// Replace with your app icon
              const Text("매추리R(with AI)", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)), // Add your title
              const SizedBox(height: 50),
              SizedBox(
                width: 250, // 원하는 너비로 변경
                height: 60, // 원하는 높이로 변경
                child: ElevatedButton(
                  onPressed: () async {
                    if (isLoggedIn!= null) {
                      Navigator.pushReplacementNamed(context, '/cost-input');
                    } else {
                      AuthFunctions authfunctions = AuthFunctions();
                      authfunctions.signInWithGoogle(ref);
                      UserDataUpload userDataUpload = UserDataUpload();
                      userDataUpload.addUserToFirestore();
                      UserDataUpload userDataUpload2 = UserDataUpload();
                      userDataUpload2.checkAndAddDefaultUserData();
                      Navigator.pushReplacementNamed(context, '/cost-input');

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
                    authFunctions.signOut(ref);
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
                    "버전 17 변경사항: 로그인 관련 기능을 수정개선하였고, 회원탈퇴 기능을 추가하였고, 색상에 약간의 변경이 있었습니다. \n 처음 만든 앱 관리하려고 오랜만에 돌아왔는데, 슬프게도 보고서 묶어보기 & AI에게 보고서 분석 요청하기 기능은 사용해주시는 분들이 없네요.ㅠㅠ ",
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



