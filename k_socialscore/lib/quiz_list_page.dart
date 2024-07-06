import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quizpage/quiz_page.dart';

class QuizListPage extends StatelessWidget {
  const QuizListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('User not logged in'));
    }

    final quizSets = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('quiz_set')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz List'),
      ),
      body: StreamBuilder(
        stream: quizSets,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading quizzes'));
          }

          final quizzes = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return ListTile(
                title: Text(quiz['question']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPage(quizId: quiz.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
