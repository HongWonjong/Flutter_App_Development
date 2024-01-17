import 'package:flutter/material.dart';

class NavigatorHelper {
  static void goToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
