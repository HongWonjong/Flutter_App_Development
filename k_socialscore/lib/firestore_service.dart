import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveQuizSet(Map<String, dynamic> quizSet) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not logged in');
    }

    await _db.collection('users').doc(uid).collection('quiz_set').add(quizSet);
  }

  Stream<List<Map<String, dynamic>>> getQuizSets() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not logged in');
    }

    return _db
        .collection('users')
        .doc(uid)
        .collection('quiz_set')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> updateQuizStatistics(String quizId, bool isPerfectScore) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not logged in');
    }

    final quizRef = _db
        .collection('users')
        .doc(uid)
        .collection('quiz_set')
        .doc(quizId);

    final quizDoc = await quizRef.get();
    if (!quizDoc.exists) {
      throw Exception('Quiz not found');
    }

    int clearCount = quizDoc.data()?['clearCount'] ?? 0;
    int perfectScoreCount = quizDoc.data()?['perfectScoreCount'] ?? 0;

    if (isPerfectScore) {
      perfectScoreCount++;
    }
    clearCount++;

    await quizRef.update({
      'clearCount': clearCount,
      'perfectScoreCount': perfectScoreCount,
    });
  }
}

