import 'package:flutter/material.dart';

class AdaptiveText {
  static TextStyle titleTextStyle(BuildContext context, {Color? color}) {
    double fontSize = MediaQuery.of(context).size.width * 0.08;
    return TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: color);
  }

  static TextStyle mediumTextStyle(BuildContext context, {Color? color}) {
    double fontSize = MediaQuery.of(context).size.width * 0.06;
    return TextStyle(fontSize: fontSize, color: color);
  }

  static TextStyle smallTextStyle(BuildContext context, {Color? color}) {
    double fontSize = MediaQuery.of(context).size.width * 0.03;
    return TextStyle(fontSize: fontSize, color: color);
  }
}

