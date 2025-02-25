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

  // 기기의 면적이 태블릿 크기 이상인지 확인
  static bool _isTabletSize() {
    final screenArea = _screenHeight * _screenWidth;
    return screenArea >= 576000; // 600 × 960 = 576,000 (태블릿 기준 임계값)
  }

  // 퍼센트별 크기 계산 (최대 크기 제한 적용, 태블릿 크기에 따라 조정)
  static double heightPercent(double percent, double maxSize) {
    final size = _screenHeight * percent / 100;
    final adjustedMaxSize = _isTabletSize() ? maxSize * 2 : maxSize; // 태블릿이면 최대 크기 2배
    return size > adjustedMaxSize ? adjustedMaxSize : size;
  }

  // 정의된 크기 (최대 크기 제한 포함)
  static double get h2 => heightPercent(2, 10);  // 2%, 최대 10px (태블릿: 20px)
  static double get h3 => heightPercent(3, 12);  // 3%, 최대 12px (태블릿: 24px)
  static double get h5 => heightPercent(5, 15);  // 5%, 최대 15px (태블릿: 30px)
  static double get h10 => heightPercent(10, 20); // 10%, 최대 20px (태블릿: 40px)
  static double get h20 => heightPercent(20, 200); // 20%, 최대 200px (태블릿: 400px)

  // 텍스트 크기 계산 (퍼센트별 최대 크기 적용, 태블릿 크기에 따라 조정)
  static double textSize(double percent) {
    if (percent == 2) return heightPercent(2, 10); // 최대 10px (태블릿: 20px)
    if (percent == 3) return heightPercent(3, 12); // 최대 12px (태블릿: 24px)
    if (percent == 5) return heightPercent(5, 15); // 최대 15px (태블릿: 30px)
    return heightPercent(percent, 50); // 기본 최대 50px (태블릿: 100px)
  }
}