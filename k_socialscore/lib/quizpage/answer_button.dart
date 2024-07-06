import 'package:flutter/material.dart';
import 'package:k_socialscore/overall_settings.dart';

final ButtonStyle answerButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: buttonColor,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8.0), // 직사각형에 가깝게 만들기
  ),
  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
);
