// media_query_util.dart
import 'package:flutter/widgets.dart';

class MQSize {
  static double getHeightPercentage(BuildContext context, double percentage) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * percentage;
  }

  static double getWidthPercentage(BuildContext context, double percentage) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * percentage;
  }

  // 세부 설정 변수
  static double getDetailHeight1(BuildContext context) =>
      getHeightPercentage(context, 0.02);

  static double getDetailHeight2(BuildContext context) =>
      getHeightPercentage(context, 0.05);

  static double getDetailHeight3(BuildContext context) =>
      getHeightPercentage(context, 0.1);

  static double getDetailHeight4(BuildContext context) =>
      getHeightPercentage(context, 0.2);

  static double getDetailHeight5(BuildContext context) =>
      getHeightPercentage(context, 0.3);

  static double getDetailWidth1(BuildContext context) =>
      getWidthPercentage(context, 0.02);

  static double getDetailWidth2(BuildContext context) =>
      getWidthPercentage(context, 0.05);

  static double getDetailWidth3(BuildContext context) =>
      getWidthPercentage(context, 0.1);

  static double getDetailWidth4(BuildContext context) =>
      getWidthPercentage(context, 0.2);

  static double getDetailWidth5(BuildContext context) =>
      getWidthPercentage(context, 0.3);
}
