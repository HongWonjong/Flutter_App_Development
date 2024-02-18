import 'package:website/style/language.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


Stream<List<String>> listenForResponses(
    String docId, String promptField, String responseField, String orderByField) {
  CollectionReference messagesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('discussions')
      .doc(docId)
      .collection('messages');

  return messagesRef.orderBy(orderByField, descending: true).snapshots().map(
        (querySnapshot) {
      List<String> messagesAndResponses = [];
      for (QueryDocumentSnapshot messageSnapshot in querySnapshot.docs) {
        try {
          // 중첩된 필드 접근을 위한 로직
          Timestamp timestamp;
          if (orderByField.contains('.')) {
            final parts = orderByField.split('.');
            final status = messageSnapshot[parts[0]];
            timestamp = status[parts[1]] ?? Timestamp.now();
          } else {
            timestamp = messageSnapshot[orderByField] ?? Timestamp.now();
          }
          DateTime createTime = timestamp.toDate();
          String formattedTime =
              '${createTime.year}년 ${createTime.month}월 ${createTime.day}일 ${createTime.hour}시 ${createTime.minute}분';

          String prompt = messageSnapshot[promptField] ?? '';
          String response = messageSnapshot[responseField] ?? '';

          String message =
              '내 질문: $prompt\n\n응답: $response\n\n 시간: $formattedTime';
          messagesAndResponses.add(message);
        } catch (e) {
          print('오류 발생: $e');
        }
      }
      return messagesAndResponses;
    },
  );
}

