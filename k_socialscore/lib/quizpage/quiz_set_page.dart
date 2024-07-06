import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import '../overall_settings.dart';
import 'package:k_socialscore/result_page.dart';
import 'answer_button.dart';

class QuizSetPage extends StatefulWidget {
  final String quizSetId;

  const QuizSetPage({super.key, required this.quizSetId});

  @override
  _QuizSetPageState createState() => _QuizSetPageState();
}

class _QuizSetPageState extends State<QuizSetPage> {
  int _currentQuizIndex = 0;
  bool _isAnswerSelected = false;
  bool _isCorrect = false;
  int _selectedOptionIndex = -1;
  Color _backgroundColor = initialBackgroundColor;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _playSound(String assetPath) {
    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.asset(assetPath)
      ..initialize().then((_) {
        _videoPlayerController!.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('quiz_sets')
            .doc(widget.quizSetId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final quizSet = snapshot.data!.data() as Map<String, dynamic>;
          final quizzes = quizSet['quizzes'] as List<dynamic>;

          if (_currentQuizIndex >= quizzes.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(
                    correctAnswers: quizzes.where((quiz) => quiz['isCorrect'] ?? false).length,
                    totalQuestions: quizzes.length,
                    socialPoints: quizzes.length, // Placeholder for social points calculation
                  ),
                ),
              );
            });
            return const SizedBox();
          }

          final quiz = quizzes[_currentQuizIndex];
          final imageUrl = quiz['imageUrl'] ?? '';
          final question = quiz['question'] ?? '';
          final answerExplanation = quiz['answerExplanation'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.height * 0.35,
                  color: imageUrl.isEmpty ? Colors.white : null,
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : const SizedBox(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "질문: $question",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: MediaQuery.of(context).size.aspectRatio * 2.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: quiz['options'].length,
                    itemBuilder: (context, index) {
                      final option = quiz['options'][index];
                      bool isSelected = _isAnswerSelected && _selectedOptionIndex == index;
                      bool isCorrectAnswer = _isAnswerSelected && quiz['answerIndex'] == index;

                      return ElevatedButton(
                        style: _isAnswerSelected
                            ? (isCorrectAnswer
                            ? answerButtonStyle.copyWith(backgroundColor: MaterialStateProperty.all(Colors.green))
                            : isSelected
                            ? answerButtonStyle.copyWith(backgroundColor: MaterialStateProperty.all(Colors.red))
                            : answerButtonStyle)
                            : answerButtonStyle,
                        onPressed: _isAnswerSelected
                            ? null
                            : () {
                          setState(() {
                            _isAnswerSelected = true;
                            _isCorrect = quiz['answerIndex'] == index;
                            quiz['isCorrect'] = _isCorrect;
                            _selectedOptionIndex = index;
                            _backgroundColor = _isCorrect ? Colors.green : Colors.red;
                            if (_isCorrect) {
                              _playSound('assets/ching-cheng-hanji.mp3');
                            } else {
                              _playSound('assets/siren.mp3');
                            }
                          });

                          Future.delayed(const Duration(seconds: 4), () {
                            setState(() {
                              _isAnswerSelected = false;
                              _backgroundColor = initialBackgroundColor;
                              _currentQuizIndex++;
                              _selectedOptionIndex = -1;
                              _videoPlayerController?.dispose();
                            });
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(option, style: const TextStyle(fontSize: textSize, color: textColor)),
                            if (_isAnswerSelected && _selectedOptionIndex == index)
                              Text(
                                _isCorrect ? '정답입니다!' : '오답입니다!',
                                style: const TextStyle(fontSize: textSize, color: textColor),
                              ),
                            if (_isAnswerSelected && quiz['answerIndex'] == index && !_isCorrect)
                              Text(
                                '정답',
                                style: const TextStyle(fontSize: textSize, color: Colors.green),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (_isAnswerSelected)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          answerExplanation,
                          style: const TextStyle(fontSize: textSize, color: textColor),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}






