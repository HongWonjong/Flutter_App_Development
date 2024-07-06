import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:k_socialscore/overall_settings.dart';
import 'quiz_data.dart'; // quiz_data.dart 파일을 import 합니다.
import 'quiz_question.dart'; // quiz_question.dart 파일을 import 합니다.
import 'quiz_answers.dart'; // quiz_answers.dart 파일을 import 합니다.
import 'quiz_feedback.dart'; // quiz_feedback.dart 파일을 import 합니다.
import '../result_page.dart'; // result_page.dart 파일을 import 합니다.
import 'dart:async';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuizIndex = 0;
  int correctAnswers = 0;
  int socialPoints = 100; // 초기 Social Points 설정
  bool showAnswer = false;
  bool isCorrect = false;
  bool hasAnswered = false;
  final AudioPlayer audioPlayer = AudioPlayer(); // 오디오 플레이어 초기화
  Color _backgroundColor = initialBackgroundColor; // 초기 배경색 설정

  void checkAnswer(int selectedIndex) async {
    if (hasAnswered) return; // 이미 답변한 경우 추가적인 클릭을 막습니다.

    bool correct = selectedIndex == quizList[currentQuizIndex].answerIndex;

    setState(() async {
      hasAnswered = true;
      isCorrect = correct;
      showAnswer = true; // 답변 완료로 표시합니다.
      if (isCorrect) {
        correctAnswers++;
      } else {
        socialPoints -= 10; // 오답 시 Social Points 감소
        _backgroundColor = Colors.red; // 배경색을 빨간색으로 변경
        await audioPlayer.play(AssetSource('assets/사이렌.mp3')); // 경고음 재생
      }
    });

    Timer(const Duration(seconds: 5), () { // 지연시간을 5초로 설정
      setState(() {
        showAnswer = false;
        hasAnswered = false; // 다음 문제로 넘어갈 때 다시 초기화합니다.
        _backgroundColor = initialBackgroundColor; // 배경색을 원래대로 변경
        if (currentQuizIndex < quizList.length - 1) {
          currentQuizIndex++;
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(
                correctAnswers: correctAnswers,
                totalQuestions: quizList.length,
                socialPoints: socialPoints, // 결과 페이지에 Social Points 전달
              ),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Quiz currentQuiz = quizList[currentQuizIndex];
    double imageSize = MediaQuery.of(context).size.height * 0.5; // 이미지 크기를 페이지 높이의 50%로 설정

    return Scaffold(
      backgroundColor: _backgroundColor, // 동적으로 변경된 배경색 사용
      appBar: AppBar(
        title: const Text('Quiz Page'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical, // 수직 스크롤 가능하도록 수정
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                QuizQuestion(quiz: currentQuiz, imageSize: imageSize),
                QuizAnswers(quiz: currentQuiz, onAnswerSelected: checkAnswer),
                if (showAnswer)
                  QuizFeedback(
                    isCorrect: isCorrect,
                    explanation: currentQuiz.answerExplanation,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




