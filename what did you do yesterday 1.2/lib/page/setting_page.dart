import 'package:flutter/material.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/component/app_bar.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'main_page.dart';
import 'package:freedomcompass/function/navigator.dart';
import 'package:freedomcompass/component/sized_box.dart';
import 'package:freedomcompass/style/text_style.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double fontSize = MediaQuery.of(context).size.height * 0.04;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar:  const CustomAppBar(
      titleText: mainpage_lan.mainPageTitle,
    ),
      body: Container(
        color: AppColors.centerColor, // 메인 페이지와 동일한 배경색 사용
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const AdaptiveSizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(mainpage_lan.mainPageTitle, style: AdaptiveText.titleTextStyle(context, color: AppColors.mainPageButtonTextColor),),

                  IconButton(
                    onPressed: () {
                      NavigatorHelper.goToPage(context, const MainPage());
                    },
                    icon: const Icon(Icons.menu),
                    iconSize: screenWidth * 0.15,
                    color: AppColors.mainPageButtonTextColor,
                  ),
                ],
              ),
              Expanded(child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenHeight * 0.02,
                ),
                padding: EdgeInsets.all(screenHeight * 0.02),
                color: AppColors.listViewBackgroundColor,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ListTile(
                      title: Text(settingpage_lan.pushSetting, style: TextStyle(color: AppColors.mainPageButtonTextColor, fontSize: fontSize)), // 텍스트 색상 추가
                      onTap: () {
                        // 언어 설정 페이지로 이동하는 동작 추가
                      },
                    ),
                    Divider(
                      height: screenHeight * 0.02,
                      color: AppColors.memoDividerColor,
                    ),
                    ListTile(
                      title: Text(settingpage_lan.passwordSetting, style: TextStyle(color: AppColors.mainPageButtonTextColor, fontSize: fontSize)), // 텍스트 색상 추가
                      onTap: () {
                        // 언어 설정 페이지로 이동하는 동작 추가
                      },
                    ),
                    Divider(
                      height: screenHeight * 0.02,
                      color: AppColors.memoDividerColor,
                    ),
                    ListTile(
                      title: Text(settingpage_lan.passwordOnOff, style: TextStyle(color: AppColors.mainPageButtonTextColor, fontSize: fontSize)), // 텍스트 색상 추가
                      onTap: () {
                        // 언어 설정 페이지로 이동하는 동작 추가
                      },
                    ),
                    Divider(
                      height: screenHeight * 0.02,
                      color: AppColors.memoDividerColor,
                    ),
                    ListTile(
                      title: Text(settingpage_lan.killSwitchPurchase, style: TextStyle(color: AppColors.mainPageButtonTextColor, fontSize: fontSize)), // 텍스트 색상 추가
                      onTap: () {
                        // 언어 설정 페이지로 이동하는 동작 추가
                      },
                    ),
                    Divider(
                      height: screenHeight * 0.02,
                      color: AppColors.memoDividerColor,
                    ),
                    ListTile(
                      title: Text(settingpage_lan.killSwitchStatus, style: TextStyle(color: AppColors.mainPageButtonTextColor, fontSize: fontSize)), // 텍스트 색상 추가
                      onTap: () {
                        // 언어 설정 페이지로 이동하는 동작 추가
                      },
                    ),
                  ],
                ),

              ),)
            ],
          ),
        ),
      ),
    );
  }
}
