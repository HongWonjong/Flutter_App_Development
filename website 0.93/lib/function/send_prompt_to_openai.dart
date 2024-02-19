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
  StreamController<String> messageStreamController = StreamController<String>();
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  DocumentReference userDocRef = usersRef.doc(uid);
  OpenAI.apiKey = await fetchGpt35ApiKey(); // API 키 가져오기

  final userMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(text),
    ],
    role: OpenAIChatMessageRole.user,
  );

  try {
    DocumentSnapshot userDoc = await userDocRef.get();
    int geminiPoints = userDoc['GeminiPoint'] ?? 0;

    if (geminiPoints < pointCost) {
      print('포인트가 부족합니다.');
      return;
    }

    await userDocRef.update({'GeminiPoint': FieldValue.increment(-pointCost)});

    final chatStream = OpenAI.instance.chat.createStream(
      model: "ft:gpt-3.5-turbo-1106:personal::8s0kD8jw", // 내가 커스텀으로 만든 모델.
      messages: [userMessage],
      seed: 423,
      n: 2,
    );

    chatStream.listen(
          (streamChatCompletion) {
        final oneWord = streamChatCompletion.choices.first.delta.content;
        print(oneWord![0].text);
        final oneWordString = oneWord[0].text.toString(); // 문자열을 추출
        messageStreamController.add(oneWordString); // StreamController에 추가
      },
      onDone: () async {
        // StreamController를 닫습니다.
        messageStreamController.close();
        // 최종 응답을 Firestore에 저장
        CollectionReference discussionsRef = userDocRef.collection('discussions');
        DocumentReference discussionRef = discussionsRef.doc(docId);

        await discussionRef.collection('messages').add({
          messageFieldName: text,
          responseKeyName: finalResponse, // 최종 문자열 사용
          "createTime": FieldValue.serverTimestamp(),
        });
      },
      onError: (error) => print("Error in stream: $error"),
    );

    // StreamController의 스트림을 구독하고, 각 문자열을 finalResponse에 누적합니다.
    messageStreamController.stream.listen(
          (data) {
        finalResponse += data; // 각 문자열을 누적
      },
      onDone: () {
        // 스트림이 완료되면 여기에서는 아무것도 할 필요가 없습니다.
        // 필요한 모든 처리는 chatStream의 onDone에서 수행됩니다.
      },
      onError: (error) => print("Error in messageStreamController: $error"),
    );
  } catch (e) {
    print('처리 중 에러 발생: $e');
  }
}


