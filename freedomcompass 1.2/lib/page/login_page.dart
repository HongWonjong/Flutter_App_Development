import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/app_bar.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/style/sized_box.dart';
import 'package:freedomcompass/style/navigator.dart';
import 'main_page.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // 사용자가 로그인을 취소한 경우

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Google 로그인 오류: $e');
      // 오류 처리 로직을 추가하세요 (예: 사용자에게 알림을 표시하거나 다른 조치를 취함)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        titleText: loginpage_lan.loginPageTitle,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigButton( // 이 부분을 수정
              onPressed: () {
                _signInWithGoogle();
              },
              buttonColor: Colors.blueAccent,
              buttonText: loginpage_lan.signInWithGoogle,
              textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.buttonTextColor),

            ),
            const AdaptiveSizedBox(),
            BigButton(
              onPressed: () {
                // Twitter 로그인 버튼이 눌렸을 때 호출할 함수
                // _signInWithTwitter();
              },
              buttonColor: Colors.black,
              buttonText: loginpage_lan.signInWithX,
              textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.buttonTextColor)),

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
              textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.buttonTextColor),
            ),
            const AdaptiveSizedBox(),
            const AdaptiveSizedBox(),
            const AdaptiveSizedBox(),
            MediumButton(
              onPressed: () {
                NavigatorHelper.goToPage(context, MainPage());
              },
              buttonColor: Colors.grey,
              buttonText: loginpage_lan.justUse,
              textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.buttonTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

