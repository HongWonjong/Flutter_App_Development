import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResponseProcessingService {
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  String? _lastResponseId;
  List<String> _responseQueue = [];
  Set<String> _processedResponses = {}; // 이미 처리된 응답을 추적

  ResponseProcessingService() {
    _flutterTts = FlutterTts();
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _processQueue();
    });
    _loadProcessedResponses(); // 앱 초기화 시 저장된 응답 로드
  }

  String? get lastResponseId => _lastResponseId;
  set lastResponseId(String? value) => _lastResponseId = value;

  Future<void> addResponseToQueue(String response) async {
    if (!_processedResponses.contains(response)) {
      _responseQueue.insert(0, response); // 큐의 앞에 추가하여 오래된 응답부터 읽기
      _processedResponses.add(response);
      await _saveProcessedResponse(response); // 응답을 파이어스토어에 저장
      _processQueue();
    }
  }

  void _processQueue() {
    if (!_isSpeaking && _responseQueue.isNotEmpty) {
      final nextResponse = _responseQueue.removeLast(); // 오래된 응답부터 읽기
      _speak(nextResponse);
    }
  }

  void _speak(String text) async {
    _isSpeaking = true;
    await _flutterTts.setLanguage("ko-KR");
    await _flutterTts.setPitch(1.2);
    await _flutterTts.setSpeechRate(1.1);
    //await _flutterTts.getVoices; // 현재 테스트 중,
    await _flutterTts.speak(text);
  }

  Future<void> _saveProcessedResponse(String response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userRef.collection('processed_responses').doc(response).set({'response': response});
    }
  }

  Future<void> _loadProcessedResponses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final querySnapshot = await userRef.collection('processed_responses').get();
      for (var doc in querySnapshot.docs) {
        _processedResponses.add(doc.id);
      }
    }
  }
}


