import 'package:flutter/material.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/textstyle.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(loginpage_lan.loginPageTitle,
        style: titleTextStyle,
          softWrap: true,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Google 로그인 버튼이 눌렸을 때 호출할 함수
                // _signInWithGoogle();
              },
              child:  Text(loginpage_lan.signInWithGoogle,
              style: mediumTextStyle,),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Twitter 로그인 버튼이 눌렸을 때 호출할 함수
                // _signInWithTwitter();
              },
              child:  Text(loginpage_lan.signInWithX,
              style: mediumTextStyle,),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Kakao 로그인 버튼이 눌렸을 때 호출할 함수
                // _signInWithKakao();
              },
              child:  Text(loginpage_lan.signInWithKaKao,
              style: mediumTextStyle,),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // 네이버 로그인 버튼이 눌렸을 때 호출할 함수
                // _signInWithNaver();
              },
              child:  Text(loginpage_lan.signInWithNaver,
              style: mediumTextStyle),
            ),
          ],
        ),
      ),
    );
  }
}

