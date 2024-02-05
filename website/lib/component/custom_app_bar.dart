// custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:website/style/language.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(mainpage_lan.appBarTitle) ,
      backgroundColor: Colors.blue,
    );
  }
}
