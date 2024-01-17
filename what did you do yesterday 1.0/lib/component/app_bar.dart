import 'package:flutter/material.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/style/color.dart';

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
    double screenHeight = MediaQuery.of(context).size.height;

    return AppBar(
      centerTitle: true,
      title: Text(
      titleText ?? "글자 안넣었을 때 나오는 글자",
      style: AdaptiveText.titleTextStyle(context, color: AppColors.mainPageButtonTextColor),
    ),
      backgroundColor: AppColors.appBarColor,
    );
  }
}

