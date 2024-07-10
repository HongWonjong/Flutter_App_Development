import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:website/function/listen_for_response.dart';
import 'package:website/function/response_to_tts.dart';
import 'package:website/function/speech_recognition.dart';

class AIVtuberWidget extends StatefulWidget {
  const AIVtuberWidget({super.key});

  @override
  _AIVtuberWidgetState createState() {
    return _AIVtuberWidgetState();
  }
}

class _AIVtuberWidgetState extends State<AIVtuberWidget> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final String docId = "GPT35_VTuber";
  final String messageFieldName = "gpt35_prompt";
  final String responseFieldName = "gpt35_response";
  final String orderByField = "status.created_at";
  late SpeechRecognitionService _speechService;
  late ResponseToTTS _responseService;

  @override
  void initState() {
    super.initState();
    _speechService = SpeechRecognitionService(
      onResult: _onSpeechResult,
      onListeningStateChanged: _onListeningStateChanged,
    );
    _responseService = ResponseToTTS();
    _speechService.initSpeech(context);
  }

  void _onSpeechResult(String text) {
    _speechService.sendTextToFirestore(text, uid, docId, messageFieldName);
  }

  void _onListeningStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: SizedBox(
              height: 150,
              width: 150,
              child: Image.asset(_speechService.currentImage),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _speechService.text,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: () => _speechService.listen(context),
            child: Icon(_speechService.isListening ? Icons.mic : Icons.mic_none),
          ),
          SizedBox(
            child: StreamBuilder<List<Map<String, String>>>(
              stream: listenForResponsesWithQuestions(docId, messageFieldName, responseFieldName, orderByField),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No responses yet');
                } else {
                  final responses = snapshot.data!;
                  if (responses.isNotEmpty) {
                    for (final responseMap in responses) {
                      final question = responseMap[messageFieldName];
                      final response = responseMap[responseFieldName];
                      if (response != null && response != _responseService.lastResponseId) {
                        final questionPart = question?.split('&&&')[1] ?? ''; // &&&을 기준으로 다음 부분만 추출하여 질문으로 장기기억에 저장
                        _responseService.addResponseToQueue(response, questionPart);
                        _responseService.lastResponseId = response;
                      }
                    }
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: responses.map((responseMap) {
                      final question = responseMap[messageFieldName]?.split('&&&')[1]; // 질문 부분만 추출
                      final response = responseMap[responseFieldName];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (question != null) Text('질문: $question'),
                            if (response != null) Text('응답: $response'),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}





