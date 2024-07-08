import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../overall_settings.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({Key? key}) : super(key: key);

  @override
  _CreateQuizPageState createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final _quizSetTitleController = TextEditingController();
  final List<QuizController> _quizControllers = [QuizController()];
  final List<bool> _expanded = [true];

  @override
  void dispose() {
    _quizSetTitleController.dispose();
    for (var controller in _quizControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addQuiz() {
    setState(() {
      _quizControllers.add(QuizController());
      _expanded.add(true);
    });
  }

  void _removeQuiz(int index) {
    setState(() {
      if (_quizControllers.length > 1) {
        _quizControllers.removeAt(index);
        _expanded.removeAt(index);
      }
    });
  }

  Future<void> _saveQuizSet() async {
    if (_formKey.currentState!.validate()) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        // Handle user not logged in
        return;
      }

      List<Map<String, dynamic>> quizzes = _quizControllers.map((qc) => qc.toMap()).toList();

      Map<String, dynamic> newQuizSet = {
        'title': _quizSetTitleController.text,
        'quizzes': quizzes,
        'views': 0, // 조회수 초기값 설정
        'createdAt': Timestamp.now() // 생성 날짜 추가
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('quiz_sets')
          .add(newQuizSet);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Quiz'),
        ),
        body: const Center(
          child: Text('You must be logged in to create a quiz.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz Set'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _quizSetTitleController,
                  decoration: const InputDecoration(labelText: 'Quiz Set Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quiz set title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      _expanded[index] = !isExpanded;
                    });
                  },
                  children: _quizControllers.asMap().entries.map<ExpansionPanel>((entry) {
                    int index = entry.key;
                    QuizController quizController = entry.value;
                    return ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: Text('Quiz ${index + 1}: ${quizController.questionController.text.isEmpty ? "New Question" : quizController.questionController.text}'),
                        );
                      },
                      body: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            quizController.build(context, () => setState(() {})),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _removeQuiz(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      isExpanded: _expanded[index],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addQuiz,
                  child: const Text('Add Quiz'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveQuizSet,
                  child: const Text('Save Quiz Set'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuizController {
  final TextEditingController questionController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(4, (index) => TextEditingController());
  final TextEditingController explanationController = TextEditingController();
  int _answerIndex = 0;

  void dispose() {
    questionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    explanationController.dispose();
  }

  Map<String, dynamic> toMap() {
    return {
      'question': questionController.text,
      'options': optionControllers.map((controller) => controller.text).toList(),
      'answerIndex': _answerIndex,
      'answerExplanation': explanationController.text,
      'socialPointsGain': 10, // 고정된 값으로 설정
      'socialPointsLoss': 10, // 고정된 값으로 설정
    };
  }

  Widget build(BuildContext context, VoidCallback updateParentState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: questionController,
          decoration: const InputDecoration(labelText: 'Question'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a question';
            }
            return null;
          },
        ),
        ...List.generate(4, (index) {
          return TextFormField(
            controller: optionControllers[index],
            decoration: InputDecoration(labelText: 'Option ${index + 1}'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an option';
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
              child: Text('Option ${index + 1}'),
            );
          }),
          onChanged: (value) {
            _answerIndex = value!;
            updateParentState();
          },
          decoration: const InputDecoration(labelText: 'Correct Answer'),
        ),
        TextFormField(
          controller: explanationController,
          decoration: const InputDecoration(labelText: 'Explanation'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an explanation';
            }
            return null;
          },
        ),
      ],
    );
  }
}




