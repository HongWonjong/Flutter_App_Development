import 'package:cloud_firestore/cloud_firestore.dart';
import 'fetch_processed_responses.dart';

Future<void> sendPromptToAssistantFirestore({
  required String uid,
  required String text,
  required String docId,
  required String commandFieldName,
}) async {
  // 과거 질의응답 내용 불러오기
  String pastResponses = await fetchProcessedResponses(uid);

  // 'users' 컬렉션에 접근
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  // uid를 사용하여 사용자 문서에 접근
  DocumentReference userDocRef = usersRef.doc(uid);

  // 사용자 문서 내의 'assistantDiscussions' 컬렉션에 접근
  CollectionReference assistantDiscussionsRef = userDocRef.collection('discussions');

  // 해당 docId의 문서가 이미 존재하는지 확인
  DocumentSnapshot discussionDoc = await assistantDiscussionsRef.doc(docId).get();

  if (!discussionDoc.exists) {
    // 존재하지 않는 경우, 새로 생성
    await assistantDiscussionsRef.doc(docId).set({});
  }

  // 'commands' 컬렉션에 새 명령어 문서 추가
  DocumentReference discussionRef = assistantDiscussionsRef.doc(docId);
  CollectionReference commandsRef = discussionRef.collection('commands');

  // 과거 질의응답 내용을 포함한 명령어 생성
  String command = """너는 사용자의 요청을 듣고 요청에 맞는 연동기능이 있는 코드를 시작하기 위한 명령어를 답변으로 내놓은 보조ai야.
  사용자의 요청 사항 중 현재의 날씨를 물어보는 구체적인 내용이 있다면 답변으로 "오늘날씨" 라는 대답을 하고, 아니라면 "요청없음"이라고 대답해. 지금부터 요청이야 &&&
   $text""";

  await commandsRef.add({
    commandFieldName: command,
  });
}
