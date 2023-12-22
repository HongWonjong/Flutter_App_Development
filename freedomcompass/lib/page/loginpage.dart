import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freedomcompass/l10n/language.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  void _signInWithEmailAndPassword() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      // 로그인 실패 시 처리
      print(loginpage_lan.loginFailureMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(loginpage_lan.loginPageTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: loginpage_lan.emailLabel),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: loginpage_lan.passwordLabel,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_passwordVisible,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _signInWithEmailAndPassword,
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // 버튼 배경색
                textStyle: const TextStyle(color: Colors.white), // 텍스트 색상
              ),
              child: const Text(loginpage_lan.loginButton),
            ),
            const SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                // 회원가입 페이지로 이동하는 코드 추가
              },
              child: const Text(loginpage_lan.signupButton),
            ),
            TextButton(
              onPressed: () {
                // 비밀번호 재설정 페이지로 이동하는 코드 추가
              },
              child: const Text(loginpage_lan.resetPasswordButton),
            ),
          ],
        ),
      ),
    );
  }
}

