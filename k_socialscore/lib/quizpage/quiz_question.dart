import 'package:flutter/material.dart';
import '../overall_settings.dart';
import 'quiz_data.dart';

class QuizQuestion extends StatelessWidget {
  final Quiz quiz;
  final double imageSize;

  const QuizQuestion({required this.quiz, required this.imageSize, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          quiz.question,
          style: const TextStyle(
            color: textColor,
            fontSize: questionText,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20.0),
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: quiz.image != null
              ? Image.asset(
            quiz.image!,
            fit: BoxFit.contain, // 이미지를 세로 길이에 맞게 조절
          )
              : const SizedBox(),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
