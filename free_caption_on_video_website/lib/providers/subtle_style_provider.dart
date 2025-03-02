import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubtitleStyleState {
  final double fontSize;
  final String fontFamily;
  final Color textColor;
  final double bgHeight;
  final Color bgColor;
  final double subtitlePosition;

  const SubtitleStyleState({
    required this.fontSize,
    required this.fontFamily,
    required this.textColor,
    required this.bgHeight,
    required this.bgColor,
    required this.subtitlePosition,
  });

  SubtitleStyleState copyWith({
    double? fontSize,
    String? fontFamily,
    Color? textColor,
    double? bgHeight,
    Color? bgColor,
    double? subtitlePosition,
    double? textOpacity,
    double? bgOpacity,
  }) {
    return SubtitleStyleState(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      textColor: textColor ?? this.textColor,
      bgHeight: bgHeight ?? this.bgHeight,
      bgColor: bgColor ?? this.bgColor,
      subtitlePosition: subtitlePosition ?? this.subtitlePosition,
    );
  }
}

// 전역 상태로 스타일 유지
final subtitleStyleProvider = StateProvider<SubtitleStyleState>((ref) {
  return const SubtitleStyleState(
    fontSize: 20.0,
    fontFamily: 'Noto Sans',
    textColor: Colors.white,
    bgHeight: 0.0, // 초기 높이는 0으로 설정
    bgColor: Colors.black,
    subtitlePosition: 10.0,
  );
});