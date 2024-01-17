import 'package:flutter/material.dart';
import 'package:freedomcompass/component/icon.dart';


// 하단에는 채팅입력창이 들어갈 예정이므로 이건 개발 중지다. 수고 많았다.
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
          AdaptiveIcons.homeIcon(),
          AdaptiveIcons.searchIcon(),
          AdaptiveIcons.favoriteIcon(),
          AdaptiveIcons.notificationsIcon(),
          AdaptiveIcons.settingsIcon(),
        ],
      ),
    );
  }
}

