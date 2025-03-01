import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 자막 스타일 상태 클래스
class SubtitleStyleState {
  final double fontSize;
  final String fontFamily;
  final Color textColor;
  final double textOpacity;
  final double bgHeight;
  final Color bgColor;
  final double bgOpacity;
  final double subtitlePosition;

  SubtitleStyleState({
    this.fontSize = 20.0,
    this.fontFamily = 'Roboto',
    this.textColor = Colors.white,
    this.textOpacity = 1.0,
    this.bgHeight = 40.0,
    this.bgColor = Colors.black,
    this.bgOpacity = 0.5,
    this.subtitlePosition = 10.0,
  });

  // 상태 복사 메서드
  SubtitleStyleState copyWith({
    double? fontSize,
    String? fontFamily,
    Color? textColor,
    double? textOpacity,
    double? bgHeight,
    Color? bgColor,
    double? bgOpacity,
    double? subtitlePosition,
  }) {
    return SubtitleStyleState(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      textColor: textColor ?? this.textColor,
      textOpacity: textOpacity ?? this.textOpacity,
      bgHeight: bgHeight ?? this.bgHeight,
      bgColor: bgColor ?? this.bgColor,
      bgOpacity: bgOpacity ?? this.bgOpacity,
      subtitlePosition: subtitlePosition ?? this.subtitlePosition,
    );
  }
}

// 상태 관리용 Notifier
class SubtitleStyleNotifier extends StateNotifier<SubtitleStyleState> {
  SubtitleStyleNotifier() : super(SubtitleStyleState());

  void update({
    double? fontSize,
    String? fontFamily,
    Color? textColor,
    double? textOpacity,
    double? bgHeight,
    Color? bgColor,
    double? bgOpacity,
    double? subtitlePosition,
  }) {
    state = state.copyWith(
      fontSize: fontSize,
      fontFamily: fontFamily,
      textColor: textColor,
      textOpacity: textOpacity,
      bgHeight: bgHeight,
      bgColor: bgColor,
      bgOpacity: bgOpacity,
      subtitlePosition: subtitlePosition,
    );
  }
}

// Riverpod 프로바이더 정의
final subtitleStyleProvider = StateNotifierProvider<SubtitleStyleNotifier, SubtitleStyleState>(
      (ref) => SubtitleStyleNotifier(),
);