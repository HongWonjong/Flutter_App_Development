// message_functions.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Stream<List<String>> listenForMessages() {
  CollectionReference messagesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('discussions')
      .doc('연습용토론계정')
      .collection('messages');

  return messagesRef.orderBy('createTime', descending: true).snapshots().map(
        (querySnapshot) {
      List<String> messagesAndResponses = [];
      for (QueryDocumentSnapshot messageSnapshot in querySnapshot.docs) {
        Timestamp timestamp = messageSnapshot['createTime'] ?? Timestamp.now();
        DateTime createTime = timestamp.toDate();

        String prompt = messageSnapshot['prompt'] ?? '';
        String response = messageSnapshot['response'] ?? '';

        String message = 'Prompt: $prompt\nResponse: $response\nCreate Time: $createTime';
        messagesAndResponses.add(message);
      }
      return messagesAndResponses;
    },
  );
}

