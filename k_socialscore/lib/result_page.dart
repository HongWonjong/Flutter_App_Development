import 'package:flutter/material.dart';
import 'overall_settings.dart'; // overall_settings.dart 파일을 import 합니다.

class ResultPage extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int socialPoints;

  const ResultPage({required this.correctAnswers, required this.totalQuestions, required this.socialPoints, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: initialBackgroundColor,
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '퀴즈를 완료했습니다!',
                style: const TextStyle(
                  color: textColor,
                  fontSize: textSize,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              Text(
                '총 $totalQuestions 문제 중 $correctAnswers 문제를 맞췄습니다.',
                style: const TextStyle(
                  color: textColor,
                  fontSize: textSize,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              Text(
                'Social Points: $socialPoints',
                style: const TextStyle(
                  color: textColor,
                  fontSize: textSize,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  '처음으로 돌아가기',
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

