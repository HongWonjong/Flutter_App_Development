import 'package:website/style/language.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Stream<List<String>> listenForGeminiProResponse() {
  CollectionReference messagesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('discussions')
      .doc(FunctionLan.geminiDoc)
      .collection('messages');

  return messagesRef.orderBy('createTime', descending: true).snapshots().map(
        (querySnapshot) {
      List<String> messagesAndResponses = [];
      for (QueryDocumentSnapshot messageSnapshot in querySnapshot.docs) {
        try {
          Timestamp timestamp = messageSnapshot['createTime'] ?? Timestamp.now();
          DateTime createTime = timestamp.toDate();
          String formattedTime = '${createTime.year}년 ${createTime.month}월 ${createTime.day}일 ${createTime.hour}시 ${createTime.minute}분'; // 분 단위까지 표시

          String prompt = messageSnapshot['prompt'] ?? '';
          String response = messageSnapshot['response'] ?? '';

          String message = '내 질문: $prompt\nGemini Pro: $response\n 시간: $formattedTime';
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
      .doc(FunctionLan.gpt35Doc)
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
          String formattedTime = '${createTime.year}년 ${createTime.month}월 ${createTime.day}일 ${createTime.hour}시 ${createTime.minute}분'; // 분 단위까지 표시

          String prompt = messageSnapshot['gpt35_prompt'] ?? '';
          String response = messageSnapshot['gpt35_response'] ?? '';

          String message = '내 질문: $prompt\nGPT3.5: $response\n 시간: $formattedTime';
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

Stream<List<String>> listenForGPT4Response() {
  CollectionReference messagesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('discussions')
      .doc(FunctionLan.gpt4Doc)
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
          String formattedTime = '${createTime.year}년 ${createTime.month}월 ${createTime.day}일 ${createTime.hour}시 ${createTime.minute}분'; // 분 단위까지 표시

          String prompt = messageSnapshot['gpt4_prompt'] ?? '';
          String response = messageSnapshot['gpt4_response'] ?? '';

          String message = '내 질문: $prompt\nGPT4: $response\n 시간: $formattedTime';
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

