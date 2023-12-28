import 'package:flutter/material.dart';
import 'package:freedomcompass/style/bottom_bar.dart';
import 'package:freedomcompass/style/app_bar.dart';
import 'package:freedomcompass/function/osm_map.dart';


class MainPage extends StatelessWidget {
  const MainPage({Key? key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double targetWidth = screenWidth * 0.9;

    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: SizedBox(
          width: targetWidth,
          height: targetWidth, // 가로 길이의 90%를 높이로 사용
          child: MapWidget(),
        ),
      ),
      bottomNavigationBar: const Material(
        child: CustomBottomBar(),
      ),
    );
  }
}
