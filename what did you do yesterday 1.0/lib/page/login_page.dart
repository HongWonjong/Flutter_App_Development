import 'package:flutter/material.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/component/app_bar.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/component/sized_box.dart';
import 'package:freedomcompass/function/navigator.dart';
import 'main_page.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/function/user_repository.dart';
import 'package:freedomcompass/function/sign_in_function.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final UserRepository _userRepository = UserRepository();


  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: const CustomAppBar(
        titleText: loginpage_lan.loginPageTitle,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenHeight * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigButton( // 이 부분을 수정
              onPressed: () async {
                await AuthFunctions.signInWithGoogle();
                await _userRepository.addUserToFirestore();

              },
              buttonColor: Colors.blueAccent,
              buttonText: loginpage_lan.signInWithGoogle,
              textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.loginPageButtonTextColor),

            ),
            const AdaptiveSizedBox(),
            BigButton(
              onPressed: () {
                // Twitter 로그인 버튼이 눌렸을 때 호출할 함수
                // _signInWithTwitter();
              },
              buttonColor: Colors.black,
              buttonText: loginpage_lan.signInWithX,
              textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.loginPageButtonTextColor)),

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
              textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.loginPageButtonTextColor),
            ),
            const AdaptiveSizedBox(),
            const AdaptiveSizedBox(),
            const AdaptiveSizedBox(),
            MediumButton(
              onPressed: () {
                NavigatorHelper.goToPage(context, const MainPage());
              },
              buttonColor: Colors.grey,
              buttonText: loginpage_lan.justUse,
              textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.loginPageButtonTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

