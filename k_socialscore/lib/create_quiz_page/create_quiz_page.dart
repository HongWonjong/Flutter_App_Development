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

  Future<void> _saveQuiz() async {
    if (_formKey.currentState!.validate()) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        // Handle user not logged in
        return;
      }

      Map<String, dynamic> newQuiz = {
        'question': _questionController.text,
        'options': _optionControllers.map((controller) => controller.text).toList(),
        'answerIndex': _answerIndex,
        'answerExplanation': _explanationController.text,
        'socialPointsGain': 10, // 고정된 값으로 설정
        'socialPointsLoss': 10, // 고정된 값으로 설정
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('quiz_set')
          .add(newQuiz);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    controller: _optionControllers[index],
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
                    setState(() {
                      _answerIndex = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Correct Answer'),
                ),
                TextFormField(
                  controller: _explanationController,
                  decoration: const InputDecoration(labelText: 'Explanation'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an explanation';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveQuiz,
                  child: const Text('Save Quiz'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

