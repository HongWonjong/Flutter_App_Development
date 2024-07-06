import 'package:flutter/material.dart';
import 'package:k_socialscore/overall_settings.dart';

class QuizFeedback extends StatelessWidget {
  final bool isCorrect;
  final String explanation;

  const QuizFeedback({
    required this.isCorrect,
    required this.explanation,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isCorrect ? "정답입니다!" : "오답입니다!",
          style: const TextStyle(
            color: textColor,
            fontSize: textSize,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10.0),
        Text(
          explanation,
          style: const TextStyle(
            color: textColor,
            fontSize: textSize,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
