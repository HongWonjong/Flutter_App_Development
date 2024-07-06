import 'package:flutter/material.dart';
import '../overall_settings.dart';
import '../quizpage/quiz_page.dart'; // 퀴즈 페이지 import
import '../create_quiz_page/create_quiz_page.dart'; // 퀴즈 작성 페이지 import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _quizIdController = TextEditingController();

  @override
  void dispose() {
    _quizIdController.dispose();
    super.dispose();
  }

  void _navigateToQuizPage(BuildContext context) {
    final quizId = _quizIdController.text;
    if (quizId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizPage(quizId: quizId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('퀴즈 ID를 입력해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: initialBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                descriptionText,
                style: TextStyle(
                  color: textColor,
                  fontSize: questionText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _quizIdController,
                decoration: const InputDecoration(
                  labelText: '퀴즈 ID 입력',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                ),
                onPressed: () => _navigateToQuizPage(context),
                child: const Text(
                  '게임 시작',
                  style: TextStyle(
                    color: textColor,
                    fontSize: textSize,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateQuizPage()),
                  );
                },
                child: const Text(
                  '퀴즈 만들기',
                  style: TextStyle(
                    color: textColor,
                    fontSize: textSize,
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

