import 'package:flutter/material.dart';
import 'package:freedomcompass/style/icon.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});


  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight;
    containerHeight = screenHeight / 15;

    return Container(
      height: containerHeight,
      color: Colors.white24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              // Home 아이콘을 클릭했을 때 실행되는 코드
            },
            child: AdaptiveIcons.homeIcon(),
          ),
          InkWell(
            onTap: () {
              // Search 아이콘을 클릭했을 때 실행되는 코드
            },
            child: AdaptiveIcons.searchIcon(),
          ),
          InkWell(
            onTap: () {
              // Favorite 아이콘을 클릭했을 때 실행되는 코드
            },
            child: AdaptiveIcons.favoriteIcon(),
          ),
          InkWell(
            onTap: () {
              // Notifications 아이콘을 클릭했을 때 실행되는 코드
            },
            child: AdaptiveIcons.notificationsIcon(),
          ),
          InkWell(
            onTap: () {
              // Settings 아이콘을 클릭했을 때 실행되는 코드
            },
            child: AdaptiveIcons.settingsIcon(),
          ),
        ],
      ),
    );
  }
}

