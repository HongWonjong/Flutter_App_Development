import 'package:flutter/material.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/style/sized_box.dart';
import 'package:freedomcompass/style/navigator.dart';
import 'main_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(loginpage_lan.loginPageTitle,
        style: AdaptiveText.titleTextStyle(context,color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigButton( // 이 부분을 수정
              onPressed: () {
                // Google 로그인 버튼이 눌렸을 때 호출할 함수
                // _signInWithGoogle();
              },
              buttonColor: Colors.blueAccent,
              buttonText: loginpage_lan.signInWithGoogle,
              textStyle: AdaptiveText.mediumTextStyle(context, color: Colors.white),

            ),
            const AdaptiveSizedBox(),
            BigButton(
              onPressed: () {
                // Twitter 로그인 버튼이 눌렸을 때 호출할 함수
                // _signInWithTwitter();
              },
              buttonColor: Colors.black,
              buttonText: loginpage_lan.signInWithX,
              textStyle: AdaptiveText.mediumTextStyle(context, color: Colors.white)),

            const AdaptiveSizedBox(),
            BigButton(
              onPressed: () {
                // Kakao 로그인 버튼이 눌렸을 때 호출할 함수
                // _signInWithKakao();
              },
              buttonColor: Colors.yellowAccent,
              buttonText: loginpage_lan.signInWithKaKao,
              textStyle: AdaptiveText.mediumTextStyle(context, color: Colors.brown),
            ),
            const AdaptiveSizedBox(),
            BigButton(
              onPressed: () {
                // 네이버 로그인 버튼이 눌렸을 때 호출할 함수
                // _signInWithNaver();
              },
              buttonColor: Colors.green,
              buttonText: loginpage_lan.signInWithNaver,
              textStyle: AdaptiveText.mediumTextStyle(context, color: Colors.white),
            ),
            const AdaptiveSizedBox(),
            const AdaptiveSizedBox(),
            const AdaptiveSizedBox(),
            BigButton(
              onPressed: () {
                NavigatorHelper.goToPage(context, const MainPage());
              },
              buttonColor: Colors.white,
              buttonText: loginpage_lan.justUse,
              textStyle: AdaptiveText.mediumTextStyle(context, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

