import 'package:flutter/material.dart';
import '../overall_settings.dart';
import '../quizpage/quiz_data.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({Key? key}) : super(key: key);

  @override
  _CreateQuizPageState createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _optionControllers = List.generate(4, (index) => TextEditingController());
  final _explanationController = TextEditingController();
  int _answerIndex = 0;

  @override
  void dispose() {
    _questionController.dispose();
    _optionControllers.forEach((controller) => controller.dispose());
    _explanationController.dispose();
    super.dispose();
  }

  void _saveQuiz() {
    if (_formKey.currentState!.validate()) {
      Quiz newQuiz = Quiz(
        question: _questionController.text,
        options: _optionControllers.map((controller) => controller.text).toList(),
        answerIndex: _answerIndex,
        image: null,
        answerExplanation: _explanationController.text,
        socialPointsGain: 10, // 고정된 값으로 설정
        socialPointsLoss: 10, // 고정된 값으로 설정
      );

      // quizList에 새로운 퀴즈를 추가합니다.
      quizList.add(newQuiz);

      // 퀴즈 저장 후 이전 화면으로 돌아갑니다.
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: initialBackgroundColor,
      appBar: AppBar(
        title: const Text('Create Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _questionController,
                  decoration: const InputDecoration(labelText: '질문'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '질문을 적어주세요';
                    }
                    return null;
                  },
                ),
                ...List.generate(4, (index) {
                  return TextFormField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(labelText: '선택지 ${index + 1}'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '선택지를 적어주세요';
                      }
                      return null;
                    },
                  );
                }),
                DropdownButtonFormField<int>(
                  value: _answerIndex,
                  items: List.generate(4, (index) {
                    return DropdownMenuItem(
                      value: index,
                      child: Text('선택지 ${index + 1}'),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _answerIndex = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: '정답'),
                ),
                TextFormField(
                  controller: _explanationController,
                  decoration: const InputDecoration(labelText: '해설'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '정답인 이유에 대한 설명이나 해설을 적어주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveQuiz,
                  child: const Text('퀴즈 저장'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
