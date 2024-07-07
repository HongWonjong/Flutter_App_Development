import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:k_socialscore/overall_settings.dart';
import 'package:k_socialscore/quizpage/answer_button.dart';
import 'signup_page.dart'; // 회원가입 페이지를 import

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: initialBackgroundColor,
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: textColor)),
        backgroundColor: identifySpaceColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              style: const TextStyle(color: textColor),
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: textColor)),
            ),
            TextField(
              style: const TextStyle(color: textColor),
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: textColor)),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: answerButtonStyle,
              onPressed: () async {
                try {
                  print('Attempting to sign in');
                  UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  print('User signed in: ${userCredential.user}');
                } catch (e) {
                  print('Error during sign in: $e');
                }
              },
              child: const Text('Login', style: TextStyle(color: textColor)),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: answerButtonStyle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
              child: const Text('Go to Sign Up',style: TextStyle(color: textColor)),
            ),
          ],
        ),
      ),
    );
  }
}



