import 'package:flutter/material.dart';
import 'package:freedomcompass/style/text_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;

  const CustomAppBar({super.key, this.titleText});

  @override
  Size get preferredSize {
    double appBarHeight = MediaQueryData.fromView(WidgetsBinding.instance.window).size.height * 0.06;
    return Size.fromHeight(appBarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: FittedBox(fit: BoxFit.scaleDown,
     child: Text(
      titleText ?? "글자 안넣었을 때 나오는 글자",
      style: AdaptiveText.titleTextStyle(context, color: Colors.black),
    ), ),
      backgroundColor: Colors.blueGrey,
    );
  }
}

