import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:sexy_chess/signin_signup_page/nickname_setting_page.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? emailErrorText;
  String? passwordErrorText;

  bool isValidEmail(String email) {
    final bool isValidFormat = EmailValidator.validate(email);
    final List<String> allowedDomains = [
      '.com',
      '.net',
      '.org',
      '.edu',
      '.gov',
      '.mil',
      '.int',
      '.eu',
      '.biz',
      '.info',
      '.name',
      '.mobi',
      '.jobs',
      '.co.jp',
      '.co.uk',
      '.co.kr',
      '.co.in',
      '.co.id',
      '.co.za',
      '.co.nz',
    ]; // 예시로 일부 도메인 추가

    final bool hasCorrectDomain = allowedDomains.any((domain) => email.endsWith(domain));

    return isValidFormat && hasCorrectDomain;
  }

  bool isValidPassword(String password) {
    final hasSpecialCharacter = password.contains(RegExp(r'[-!@#$%^&*(),.?":{}|<>]'));
    final hasDigit = password.contains(RegExp(r'\d'));
    return password.length >= 10 && hasSpecialCharacter && hasDigit;
  }

  void handleSignUp() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    if (!isValidEmail(email)) {
      setState(() {
        emailErrorText = '올바른 형식으로 입력해주세요';
      });
      return;
    }

    if (!isValidPassword(password)) {
      setState(() {
        passwordErrorText = password.length < 10
            ? '10자 이상으로 비밀번호를 입력해주세요'
            : '특수문자와 숫자를 넣어주세요';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        passwordErrorText = '비밀번호가 일치하지 않습니다';
      });
      return;
    }

    try {
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Navigate to the GameScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => NicknameSettingScreen(user: userCredential.user),
        ),
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          setState(() {
            emailErrorText = '이미 회원으로 가입된 이메일입니다.';
          });
          return;
        }
      }
      if (kDebugMode) {
        print(e);
      }
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원가입에 실패했습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.white,
                ),
              ),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '이메일',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  errorText: emailErrorText,
                  filled: true,
                  fillColor: Colors.grey[700],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  errorText: passwordErrorText,
                  filled: true,
                  fillColor: Colors.grey[700],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '비밀번호 확인',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  errorText: passwordErrorText,
                  filled: true,
                  fillColor: Colors.grey[700],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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




