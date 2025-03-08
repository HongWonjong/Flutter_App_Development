import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

// 앱 테마 상태 관리 Provider
class ThemeNotifier extends StateNotifier<AppTheme> {
  static const String _prefsKey = 'app_theme';

  ThemeNotifier() : super(AppTheme.defaultTheme()) {
    _loadTheme();
  }

  // SharedPreferences에서 테마 설정 로드
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeJson = prefs.getString(_prefsKey);

      if (themeJson != null) {
        final themeMap = jsonDecode(themeJson);
        state = AppTheme.fromMap(themeMap);
      }
    } catch (e) {
      debugPrint('테마 로드 오류: $e');
      // 오류 발생 시 기본 테마 사용
      state = AppTheme.defaultTheme();
    }
  }

  // 테마 변경 및 저장
  Future<void> updateTheme(AppTheme newTheme) async {
    state = newTheme;
    _saveTheme();
  }

  // 프리셋 테마로 변경
  Future<void> setPreset(ThemePreset preset) async {
    state = AppTheme.fromPreset(preset);
    _saveTheme();
  }

  // 앱 바 색상만 변경
  Future<void> updateAppBarColor(Color color) async {
    state = state.copyWith(appBarColor: color);
    _saveTheme();
  }

  // 배경 색상만 변경
  Future<void> updateBackgroundColor(Color color) async {
    state = state.copyWith(backgroundColor: color);
    _saveTheme();
  }

  // 텍스트 색상만 변경
  Future<void> updateTextColor(Color color) async {
    state = state.copyWith(textColor: color);
    _saveTheme();
  }

  // 테마 설정 저장
  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeJson = jsonEncode(state.toMap());
      await prefs.setString(_prefsKey, themeJson);
    } catch (e) {
      debugPrint('테마 저장 오류: $e');
    }
  }
}

// 테마 Provider 정의
final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier();
});

// Material ThemeData 생성 Helper
ThemeData getThemeData(AppTheme appTheme) {
  return ThemeData(
    primaryColor: appTheme.appBarColor,
    scaffoldBackgroundColor: appTheme.backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: appTheme.appBarColor,
      foregroundColor: _contrastColor(appTheme.appBarColor),
      elevation: 0,
    ),
    textTheme: TextTheme(bodyMedium: TextStyle(color: appTheme.textColor)),
    colorScheme: ColorScheme.fromSeed(
      seedColor: appTheme.appBarColor,
      primary: appTheme.appBarColor,
      background: appTheme.backgroundColor,
      brightness: _getBrightness(appTheme.backgroundColor),
    ),
  );
}

// 배경에 따른 밝기 결정
Brightness _getBrightness(Color backgroundColor) {
  return ThemeData.estimateBrightnessForColor(backgroundColor) ==
          Brightness.dark
      ? Brightness.dark
      : Brightness.light;
}

// 배경색에 따른 대비 색상 선택 (텍스트 가독성을 위함)
Color _contrastColor(Color backgroundColor) {
  return ThemeData.estimateBrightnessForColor(backgroundColor) ==
          Brightness.dark
      ? Colors.white
      : Colors.black;
}
