import 'package:cloud_firestore/cloud_firestore.dart';
import 'fetch_processed_responses.dart';

Future<void> sendPromptToFirestore({
  required String uid,
  required String text,
  required String docId,
  required String messageFieldName,
}) async {
  // 과거 질의응답 내용 불러오기
  String pastResponses = await fetchProcessedResponses(uid);

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

  // 과거 질의응답 내용을 포함한 메시지 생성
  String prompt = "이건 너와 내가 전에 나눴던 질의응답을 저장한 내용들이야.// $pastResponses // 너는 이 내용을 장기기억으로써 생각하고, 이걸 바탕으로 나와 대화를 하면 돼. 대화 내용은 다음부터 시작이야. &&&\n$text";

  await messagesRef.add({
    messageFieldName: prompt,
  });
}

