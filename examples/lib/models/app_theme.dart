import 'package:flutter/material.dart';

// 앱 테마 프리셋 타입
enum ThemePreset {
  dark, // 다크 모드
  light, // 라이트 모드 (기본)
  nature, // 녹색 테마
  elegant, // 우아한 테마 (추가)
  sunset, // 일몰 테마 (추가)
  ocean, // 바다 테마 (추가)
}

// 앱 테마 설정 클래스
class AppTheme {
  final Color appBarColor;
  final Color backgroundColor;
  final Color textColor;
  final ThemePreset preset;

  // 기본 생성자
  const AppTheme({
    required this.appBarColor,
    required this.backgroundColor,
    required this.textColor,
    required this.preset,
  });

  // 프리셋에 따른 테마 생성
  factory AppTheme.fromPreset(ThemePreset preset) {
    switch (preset) {
      case ThemePreset.dark:
        return AppTheme(
          appBarColor: const Color(0xFF303030),
          backgroundColor: const Color(0xFF121212),
          textColor: Colors.white,
          preset: ThemePreset.dark,
        );
      case ThemePreset.light:
        return AppTheme(
          appBarColor: Colors.blue,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          preset: ThemePreset.light,
        );
      case ThemePreset.nature:
        return AppTheme(
          appBarColor: const Color(0xFF4CAF50),
          backgroundColor: const Color(0xFFE8F5E9),
          textColor: Colors.black,
          preset: ThemePreset.nature,
        );
      case ThemePreset.elegant:
        return AppTheme(
          appBarColor: const Color(0xFF5D4037), // 짙은 갈색
          backgroundColor: const Color(0xFFF5F5F5), // 미묘한 회색빛 흰색
          textColor: const Color(0xFF3E2723), // 매우 짙은 갈색
          preset: ThemePreset.elegant,
        );
      case ThemePreset.sunset:
        return AppTheme(
          appBarColor: const Color(0xFFFF5722), // 선셋 오렌지
          backgroundColor: const Color(0xFFFFF3E0), // 따뜻한 오렌지 스플래시
          textColor: const Color(0xFF3E2723), // 짙은 갈색 텍스트
          preset: ThemePreset.sunset,
        );
      case ThemePreset.ocean:
        return AppTheme(
          appBarColor: const Color(0xFF0277BD), // 짙은 푸른색
          backgroundColor: const Color(0xFFE1F5FE), // 연한 푸른색
          textColor: const Color(0xFF01579B), // 짙은 푸른색 텍스트
          preset: ThemePreset.ocean,
        );
    }
  }

  // 현재 테마 복사 후 일부 속성만 변경
  AppTheme copyWith({
    Color? appBarColor,
    Color? backgroundColor,
    Color? textColor,
    ThemePreset? preset,
  }) {
    return AppTheme(
      appBarColor: appBarColor ?? this.appBarColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      preset: preset ?? this.preset,
    );
  }

  // SharedPreferences에 저장하기 위한 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'appBarColor': appBarColor.value,
      'backgroundColor': backgroundColor.value,
      'textColor': textColor.value,
      'preset': preset.index,
    };
  }

  // SharedPreferences에서 로드한 Map에서 테마 생성
  factory AppTheme.fromMap(Map<String, dynamic> map) {
    return AppTheme(
      appBarColor: Color(map['appBarColor']),
      backgroundColor: Color(map['backgroundColor']),
      textColor: Color(map['textColor']),
      preset: ThemePreset.values[map['preset']],
    );
  }

  // 기본 테마
  factory AppTheme.defaultTheme() {
    return AppTheme.fromPreset(ThemePreset.light);
  }
}
