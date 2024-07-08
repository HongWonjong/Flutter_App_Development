import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class ResponseProcessingService {
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  String? _lastResponseId;
  List<String> _responseQueue = [];

  ResponseProcessingService() {
    _flutterTts = FlutterTts();
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _processQueue();
    });
  }

  String? get lastResponseId => _lastResponseId;
  set lastResponseId(String? value) => _lastResponseId = value;

  void addResponseToQueue(String response) {
    _responseQueue.add(response);
    _processQueue();
  }

  void _processQueue() {
    if (!_isSpeaking && _responseQueue.isNotEmpty) {
      final nextResponse = _responseQueue.removeAt(0);
      _speak(nextResponse);
    }
  }

  void _speak(String text) async {
    _isSpeaking = true;
    await _flutterTts.setLanguage("ko-KR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }
}

