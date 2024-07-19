import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Stream<List<Map<String, String>>> listenForResponsesWithQuestions(
    String docId, String promptField, String responseField, String orderByField) {
  CollectionReference messagesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('discussions')
      .doc(docId)
      .collection('messages');

  return messagesRef.orderBy(orderByField, descending: true).snapshots().map(
        (querySnapshot) {
      List<Map<String, String>> messagesAndResponses = [];
      for (QueryDocumentSnapshot messageSnapshot in querySnapshot.docs) {
        try {
          final question = messageSnapshot[promptField] as String?;
          final response = messageSnapshot[responseField] as String?;
          if (question != null || response != null) {
            messagesAndResponses.add({
              promptField: question ?? '',
              responseField: response ?? '',
            });
          }
        } catch (e) {
          print('오류 발생: $e');
        }
      }
      return messagesAndResponses;
    },
  );
}

