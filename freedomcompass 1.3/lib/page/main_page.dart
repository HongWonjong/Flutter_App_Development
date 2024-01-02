import 'package:flutter/material.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/bottom_bar.dart';
import 'package:freedomcompass/style/app_bar.dart';
import 'package:freedomcompass/function/osm_map.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/style/sized_box.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/function/user_repository.dart';


class MainPage extends StatefulWidget {
  const MainPage({Key? key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // MapWidget 인스턴스 생성
  MapWidget mapWidget = MapWidget();

  @override
  void initState() {
    super.initState();
    checkAndAddUserData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double targetWidth = screenWidth * 0.9;

    return Scaffold(
      appBar: const CustomAppBar(
        titleText: mainpage_lan.mainPageTitle,
      ),
      body: Container( // Container 추가
        color: AppColors.centerColor, // 원하는 색상으로 설정
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MediumButton(
                onPressed: () {
                  MapWidget().triggerLocationUpdate();
                },
                buttonText: mainpage_lan.setToMyPosition,
                buttonColor: AppColors.buttonColor,
                textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.buttonTextColor),
              ),
              const AdaptiveSizedBox(),
              SizedBox(
                width: targetWidth,
                height: targetWidth * 0.9,
                child: MapWidget(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Material(
        child: CustomBottomBar(),
      ),
    );
  }
}

