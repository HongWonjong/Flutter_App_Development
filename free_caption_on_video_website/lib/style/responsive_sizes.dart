import 'package:flutter/material.dart';

// 화면 크기에 따라 동적으로 크기를 계산하는 유틸리티 클래스
class ResponsiveSizes {
  static late double _screenHeight;
  static late double _screenWidth;

  // 초기화 메서드
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenHeight = mediaQuery.size.height;
    _screenWidth = mediaQuery.size.width;
  }

  // 퍼센트별 크기 계산 (최대 크기 제한 적용)
  static double heightPercent(double percent, double maxSize) {
    final size = _screenHeight * percent / 100;
    return size > maxSize ? maxSize : size;
  }

  // 정의된 크기 (최대 크기 제한 포함)
  static double get h2 => heightPercent(2, 10);  // 2%, 최대 10px
  static double get h3 => heightPercent(3, 12);  // 3%, 최대 15px
  static double get h5 => heightPercent(5, 15);  // 5%, 최대 25px
  static double get h10 => heightPercent(10, 20); // 10%, 최대 50px (임의 설정)
  static double get h20 => heightPercent(20, 200); // 10%, 최대 50px (임의 설정)


  // 텍스트 크기 계산 (퍼센트별 최대 크기 적용)
  static double textSize(double percent) {
    if (percent == 2) return heightPercent(2, 10);
    if (percent == 3) return heightPercent(3, 12);
    if (percent == 5) return heightPercent(5, 15);
    return heightPercent(percent, 50); // 기본 최대 50px
  }
}