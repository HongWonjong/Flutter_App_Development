import 'package:flutter/material.dart';
import 'answer_button.dart';
import 'quiz_data.dart';

class QuizAnswers extends StatelessWidget {
  final Quiz quiz;
  final Function(int) onAnswerSelected;

  const QuizAnswers({required this.quiz, required this.onAnswerSelected, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AnswerButton(
                  text: quiz.options[0],
                  onPressed: () => onAnswerSelected(0),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: AnswerButton(
                  text: quiz.options[1],
                  onPressed: () => onAnswerSelected(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: AnswerButton(
                  text: quiz.options[2],
                  onPressed: () => onAnswerSelected(2),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: AnswerButton(
                  text: quiz.options[3],
                  onPressed: () => onAnswerSelected(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
