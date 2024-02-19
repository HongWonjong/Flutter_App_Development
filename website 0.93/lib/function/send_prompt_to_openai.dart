import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:website/function/fetch_secret_value.dart';

Future<void> sendPromptToOpenAI({
  required String uid,
  required String text,
  required int pointCost,
  required String docId,
  required String messageFieldName,
  required String responseKeyName,
}) async {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  DocumentReference userDocRef = usersRef.doc(uid);
  OpenAI.apiKey = await fetchGpt35ApiKey();

  try {
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

    await for (var event in completionStream) {
      final firstCompletionChoice = event.choices.first;
      final responseText = firstCompletionChoice.text;

      // 사용자 문서 내의 'discussions' 컬렉션에 접근
      CollectionReference discussionsRef = userDocRef.collection('discussions');
      DocumentSnapshot discussionDoc = await discussionsRef.doc(docId).get();

      if (!discussionDoc.exists) {
        await discussionsRef.doc(docId).set({});
      }

      DocumentReference discussionRef = discussionsRef.doc(docId);
      CollectionReference messagesRef = discussionRef.collection('messages');
      await messagesRef.add({
        messageFieldName: text,
        responseKeyName: responseText, // 수정됨: responseText를 저장
        "createTime": FieldValue.serverTimestamp(),
      });

      await userDocRef.update({'GeminiPoint': FieldValue.increment(-pointCost)});
      break; // 스트림에서 첫 번째 응답만 처리 후 반복문 종료
    }
  } catch (e) {
    print('처리 중 에러 발생: $e');
    // 적절한 에러 처리 또는 사용자에게 피드백 제공
  }
}
