import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';


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
  Stream<OpenAIStreamCompletionModel> completionStream = OpenAI.instance.completion.createStream(
    model: "gpt-3.5-turbo-0125",
    prompt: text,
    maxTokens: 100,
    temperature: 0.5,
    topP: 1,
    seed: 42,
    stop: '###',
    n: 2,
  );

  // 사용자의 포인트 차감
  await userDocRef.update({'GeminiPoint': FieldValue.increment(-pointCost)});

  print('Prompt sent to Firestore!');
  print('Discussion ID: $docId');
}