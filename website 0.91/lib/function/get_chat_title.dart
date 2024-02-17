import 'package:website/style/language.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Stream<List<String>> listenForTitle(String docId, String orderByField) {
  CollectionReference messagesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('discussions')
      .doc(docId)
      .collection('messages');

  return messagesRef.orderBy(orderByField, descending: true).snapshots().map(
        (querySnapshot) {
      return querySnapshot.docs.map((messageSnapshot) {
        try {
          String title = messageSnapshot['title'] ?? '';
          Timestamp timestamp = messageSnapshot[orderByField];
          DateTime createTime = timestamp.toDate();
          return '$title\n$createTime';
        } catch (e) {
          print('Error: $e');
          return ''; // 오류가 발생한 경우 빈 문자열 반환
        }
      }).where((title) => title.isNotEmpty).toList(); // 빈 문자열 제거
    },
  );
}

// 사용 예시:
/*Stream<List<String>> geminiTitles = listenForTitle(FunctionLan.geminiDoc, 'createTime');
Stream<List<String>> gpt35Titles = listenForTitle(FunctionLan.gpt35Doc, 'status.created_at');
Stream<List<String>> gpt4Titles = listenForTitle(FunctionLan.gpt4Doc, 'status.created_at');*/
