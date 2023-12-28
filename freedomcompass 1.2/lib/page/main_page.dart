import 'package:flutter/material.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/bottom_bar.dart';
import 'package:freedomcompass/style/app_bar.dart';
import 'package:freedomcompass/function/osm_map.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/style/sized_box.dart';


class MainPage extends StatelessWidget {
  MainPage({Key? key});

  // MapWidget 인스턴스 생성
  MapWidget mapWidget = MapWidget();

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
                MapWidget().triggerLocationUpdate();
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

