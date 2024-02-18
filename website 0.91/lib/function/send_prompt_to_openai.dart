import 'package:cloud_firestore/cloud_firestore.dart';


Future<void> sendPromptToOpenAI({
  required String uid,
  required String text,
  required int pointCost,
  required String docId,
  required String messageFieldName,
  required int titleLength
}) async {
  // 타이틀 길이에 따라 텍스트의 앞부분을 잘라내어 타이틀로 사용
  String title = text.length > titleLength ? text.substring(0, titleLength) : text;

  // 'users' 컬렉션에 접근
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  // uid를 사용하여 사용자 문서에 접근
  DocumentReference userDocRef = usersRef.doc(uid);

  // 사용자가 충분한 포인트를 가지고 있는지 확인
  DocumentSnapshot userDoc = await userDocRef.get();
  int geminiPoints = userDoc['GeminiPoint'] ?? 0;

  if (geminiPoints < pointCost) {
    print('포인트가 부족합니다.');
    return;
  }

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
    'title': title,
  });

  // 사용자의 포인트 차감
  await userDocRef.update({'GeminiPoint': FieldValue.increment(-pointCost)});

  print('Prompt sent to Firestore!');
  print('Discussion ID: $docId');
}