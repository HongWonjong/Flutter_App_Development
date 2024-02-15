import 'package:website/style/language.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Stream<List<String>> listenForGeminiProTitle() {
  CollectionReference messagesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('discussions')
      .doc(FunctionLan.geminiDoc)
      .collection('messages');

  return messagesRef.orderBy('createTime', descending: true).snapshots().map(
        (querySnapshot) {
      List<String> titleList = [];
      for (QueryDocumentSnapshot messageSnapshot in querySnapshot.docs) {
        try {
          String title = messageSnapshot['title'] ?? '';
          Timestamp timestamp = messageSnapshot['createTime'];
          DateTime createTime = timestamp.toDate();
          // title과 createTime을 함께 저장
          String message = '$title\n$createTime';
          titleList.add(message);
        } catch (e) {
          print('오류 발생: $e');
        }
      }
      return titleList;
    },
  );
}


Stream<List<String>> listenForGPT35Title() {
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
      List<String> titleList = [];
      for (QueryDocumentSnapshot messageSnapshot in querySnapshot.docs) {
        try {
          String title = messageSnapshot['title'] ?? '';
          Timestamp timestamp = messageSnapshot['status.created_at'];
          DateTime createTime = timestamp.toDate();
          // title과 createTime을 함께 저장
          String message = '$title\n$createTime';
          titleList.add(message);
        } catch (e) {
          // 오류가 발생하면 해당 메시지를 무시하고 다음 메시지로 계속 진행
          print('오류 발생: $e');
        }
      }
      return titleList;
    },
  );
}

Stream<List<String>> listenForGPT4Title() {
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
      List<String> titleList = [];
      for (QueryDocumentSnapshot messageSnapshot in querySnapshot.docs) {
        try {
          String title = messageSnapshot['title'] ?? '';
          Timestamp timestamp = messageSnapshot['status.created_at'];
          DateTime createTime = timestamp.toDate();
          // title과 createTime을 함께 저장
          String message = '$title\n$createTime';
          titleList.add(message);
        } catch (e) {
          // 오류가 발생하면 해당 메시지를 무시하고 다음 메시지로 계속 진행
          print('오류 발생: $e');
        }
      }
      return titleList;
    },
  );
}