import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> sendPromptToFirestore({
  required String uid,
  required String text,
  required String docId,
  required String messageFieldName,
}) async {
  // 'users' 컬렉션에 접근
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  // uid를 사용하여 사용자 문서에 접근
  DocumentReference userDocRef = usersRef.doc(uid);

  // 사용자 문서 내의 'discussions' 컬렉션에 접근
  CollectionReference discussionsRef = userDocRef.collection('discussions');

  // 해당 docId의 문서가 이미 존재하는지 확인
  DocumentSnapshot discussionDoc = await discussionsRef.doc(docId).get();

  if (!discussionDoc.exists) {
    // 존재하지 않는 경우, 새로 생성
    await discussionsRef.doc(docId).set({});
  }

  // 'messages' 컬렉션에 새 메시지 문서 추가
  DocumentReference discussionRef = discussionsRef.doc(docId);
  CollectionReference messagesRef = discussionRef.collection('messages');
  await messagesRef.add({
    messageFieldName: text,
  });
}
