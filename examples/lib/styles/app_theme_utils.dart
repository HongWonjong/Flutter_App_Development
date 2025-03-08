import 'package:flutter/material.dart';

class AppTheme {
  // 앱 기본 색상
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.blueAccent;
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black87;
  static const Color subtitleColor = Colors.black54;

  // 메모 카드 스타일
  static BoxDecoration memoCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // 텍스트 스타일
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 14,
    color: subtitleColor,
  );

  static const TextStyle dateStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  // 앱 테마
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
    useMaterial3: true,
  );
}
