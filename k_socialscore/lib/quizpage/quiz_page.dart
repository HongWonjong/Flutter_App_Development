import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizPage extends StatelessWidget {
  final String quizId;

  const QuizPage({Key? key, required this.quizId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('User not logged in'));
    }

    final quizRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('quiz_set')
        .doc(quizId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: FutureBuilder(
        future: quizRef.get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading quiz'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Quiz not found'));
          }

          final quiz = snapshot.data!;
          final options = List<String>.from(quiz['options']);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  quiz['question'],
                  style: const TextStyle(fontSize: 24.0),
                ),
                const SizedBox(height: 20.0),
                ...options.map((option) => ElevatedButton(
                  onPressed: () {},
                  child: Text(option),
                )),
                const SizedBox(height: 20.0),
                Text('Explanation: ${quiz['answerExplanation']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}





