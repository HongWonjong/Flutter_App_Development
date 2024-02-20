import 'dart:async'; // StreamController와 Completer를 사용하기 위해 필요
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
  String finalResponse = ''; // String을 누적할 변수 초기화
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  try {
    OpenAI.apiKey = await fetchGpt35ApiKey(); // API 키 가져오기
  } catch (e) {
    print('API 키를 가져오는 중 에러 발생: $e');
    return;
  }

  final systemMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "한국말로 정중하게 대답해.",
      ),
    ],
    role: OpenAIChatMessageRole.assistant,
  );

  final userMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(text),
    ],
    role: OpenAIChatMessageRole.user,
  );

  final requestMessages = [
    systemMessage,
    userMessage,
  ];

  try {
    DocumentSnapshot userDoc = await usersRef.doc(uid).get();
    int geminiPoints = userDoc['GeminiPoint'] ?? 0;

    if (geminiPoints < pointCost) {
      print('포인트가 부족합니다.');
      return;
    }

    await usersRef.doc(uid).update({'GeminiPoint': FieldValue.increment(-pointCost)});
  } catch (e) {
    print('사용자 점수 업데이트 중 에러 발생: $e');
    return;
  }

  try {
    OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
      model: "ft:gpt-3.5-turbo-1106:personal::8s0kD8jw",
      seed: 6,
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 500,
      //// tool은 그냥 없애라. 오류만 뜸.
    );
    String jsonString = chatCompletion.choices.first.message.content!.first.text!;
    print(jsonString);
    finalResponse = jsonString;
  } catch (e) {
    print('OpenAI 챗 완성 중 에러 발생: $e');
    return;
  }

  try {
    CollectionReference discussionsRef = usersRef.doc(uid).collection('discussions');
    DocumentReference discussionRef = discussionsRef.doc(docId);

    await discussionRef.collection('messages').add({
      messageFieldName: text,
      responseKeyName: finalResponse, // 최종 문자열 사용
      "createTime": FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('Firestore에 메시지 저장 중 에러 발생: $e');
  }
}



