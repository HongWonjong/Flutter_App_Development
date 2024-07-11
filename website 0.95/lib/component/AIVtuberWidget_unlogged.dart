import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:website/function/listen_for_response.dart';
import 'package:website/function/response_to_tts.dart';
import 'package:website/function/speech_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AIVtuberWidget_Unlogged extends StatefulWidget {
  const AIVtuberWidget_Unlogged({super.key});

  @override
  _AIVtuberWidget_UnloggedState createState() {
    return _AIVtuberWidget_UnloggedState();
  }
}

class _AIVtuberWidget_UnloggedState extends State<AIVtuberWidget_Unlogged> {
  late final String uid;
  final String docId = "GPT35_VTuber";
  final String messageFieldName = "gpt35_prompt";
  final String responseFieldName = "gpt35_response";
  final String orderByField = "status.created_at";
  late SpeechRecognitionService _speechService;
  late ResponseToTTS _responseService;

  @override
  void initState() {
    super.initState();
    uid = _getUid();
    _speechService = SpeechRecognitionService(
      onResult: _onSpeechResult,
      onListeningStateChanged: _onListeningStateChanged,
    );
    _responseService = ResponseToTTS();
    _speechService.initSpeech(context);
  }

  String _getUid() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return "usable_${_generateRandomString(10)}";
    }
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  void _onSpeechResult(String text) {
    _speechService.sendTextToFirestore(text, uid, docId, messageFieldName);
  }

  void _onListeningStateChanged() {
    setState(() {});
  }

  Future<void> deleteDiscussionMessages() async {
    CollectionReference messagesRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('discussions').doc(docId).collection('messages');
    QuerySnapshot querySnapshot = await messagesRef.get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> deleteProcessedResponses() async {
    CollectionReference responsesRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('processed_responses');
    QuerySnapshot querySnapshot = await responsesRef.get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
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
          ElevatedButton(
            onPressed: () async {
              await deleteDiscussionMessages();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('대화 기록이 삭제되었습니다.')),
              );
            },
            child: Text('대화 기록 삭제'),
          ),
          ElevatedButton(
            onPressed: () async {
              await deleteProcessedResponses();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('장기 기억이 삭제되었습니다.')),
              );
            },
            child: Text('장기 기억 삭제'),
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
