import 'package:flutter/material.dart';

// 너비와 높이에 비율을 곱해 크기를 계산하는 함수들
double widthPercentage(BuildContext context, double percentage) {
  return MediaQuery.of(context).size.width * (percentage / 100);
}

double heightPercentage(BuildContext context, double percentage) {
  return MediaQuery.of(context).size.height * (percentage / 100);
}

// 적응형 텍스트 크기 설정 함수
double fontSizePercentage(BuildContext context, double percentage) {
  return MediaQuery.of(context).size.width * (percentage / 100);
}

// 다양한 글꼴 크기 설정을 위한 변수
class MQSize {
  static double get fontSize2_5 => 2.5;
  static double get fontSize4 => 4.0;
  static double get fontSize5 => 5.0;
  static double get fontSize6 => 6.0;
  static double get fontSize8 => 8.0;
  static double get fontSize10 => 10.0;
  static double get fontSize12 => 12.0;
  static double get fontSize13_5 => 13.5;
  static double get fontSize15 => 15.0;
  static double get fontSize18 => 18.0;
  static double get fontSize20 => 20.0;
  static double get fontSize22 => 22.0;
  static double get fontSize23_5 => 23.5;
  static double get fontSize25 => 25.0;
}
