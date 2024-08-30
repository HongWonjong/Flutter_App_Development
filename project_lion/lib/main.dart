import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: LoginScreen(),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7164d9), // #7164d9
            Color(0xFFfc8c6a), // #fc8c6a
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '사자',
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '당신이 누구인지 이 녀석들에게 똑똑히 알려주십시오.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            SignInButton(
              icon: Icons.g_translate,
              text: 'Continue with Google',
              onPressed: () {
                // Google 로그인 로직
              },
            ),
            SizedBox(height: 10),
            SignInButton(
              icon: Icons.apple,
              text: 'Continue with Apple',
              onPressed: () {
                // Apple 로그인 로직
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SignInButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  SignInButton({required this.icon, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      ),
      icon: Icon(icon, size: 24),
      label: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
      onPressed: onPressed,
    );
  }
}
