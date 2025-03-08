import 'package:flutter/material.dart';

/// 색상 관련 유틸리티 클래스
class ColorUtils {
  /// 배경색에 대비되는 텍스트 색상을 반환합니다 (검은색 또는 흰색)
  static Color contrastColor(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}
