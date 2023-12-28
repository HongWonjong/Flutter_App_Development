import 'package:flutter/material.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/bottom_bar.dart';
import 'package:freedomcompass/style/app_bar.dart';
import 'package:freedomcompass/function/osm_map.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/style/sized_box.dart';


class MainPage extends StatelessWidget {
  const MainPage({Key? key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double targetWidth = screenWidth * 0.9;

    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MediumButton(
              onPressed: () {
                // 버튼이 눌렸을 때 수행할 작업을 여기에 추가
              },
              buttonText: mainpage_lan.setToMyPosition,
              buttonColor: Colors.black,
              textStyle: AdaptiveText.mediumTextStyle(context, color: Colors.white),
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
      bottomNavigationBar: const Material(
        child: CustomBottomBar(),
      ),
    );
  }
}

