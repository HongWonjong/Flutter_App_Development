// message_functions.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Stream<List<String>> listenForGeminiProResponse() {
  CollectionReference messagesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('discussions')
      .doc('GeminiPro')
      .collection('messages');

  return messagesRef.orderBy('createTime', descending: true).snapshots().map(
        (querySnapshot) {
      List<String> messagesAndResponses = [];
      for (QueryDocumentSnapshot messageSnapshot in querySnapshot.docs) {
        try {
          Timestamp timestamp = messageSnapshot['createTime'] ?? Timestamp.now();
          DateTime createTime = timestamp.toDate();

          String prompt = messageSnapshot['prompt'] ?? '';
          String response = messageSnapshot['response'] ?? '';

          String message = '내 질문: $prompt\nGemini Pro: $response\n 시간: $createTime';
          messagesAndResponses.add(message);
        } catch (e) {
          // 오류가 발생하면 해당 메시지를 무시하고 다음 메시지로 계속 진행
          print('오류 발생: $e');
        }
      }
      return messagesAndResponses;
    },
  );
}

Stream<List<String>> listenForGPT35Response() {
  CollectionReference messagesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('discussions')
      .doc('GPT35')
      .collection('messages');

  return messagesRef.orderBy('status.created_at', descending: true)
      .snapshots()
      .map(
        (querySnapshot) {
      List<String> messagesAndResponses = [];
      for (QueryDocumentSnapshot messageSnapshot in querySnapshot.docs) {
        try {
          Timestamp timestamp = messageSnapshot['status']['created_at'] ?? Timestamp.now();
          DateTime createTime = timestamp.toDate();

          String prompt = messageSnapshot['gpt35_prompt'] ?? '';
          String response = messageSnapshot['gpt35_response'] ?? '';

          String message = '내 질문: $prompt\nGPT3.5: $response\n 시간: $createTime';
          messagesAndResponses.add(message);
        } catch (e) {
          // 오류가 발생하면 해당 메시지를 무시하고 다음 메시지로 계속 진행
          print('오류 발생: $e');
        }
      }
      return messagesAndResponses;
    },
  );
}

