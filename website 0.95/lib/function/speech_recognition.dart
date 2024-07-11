import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:website/function/send_voice.dart';

class SpeechRecognitionService {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Say something...";
  String _currentImage = 'assets/idle.png';
  bool _speechRecognitionAvailable = false;
  final Function(String) onResult;
  final VoidCallback onListeningStateChanged;

  SpeechRecognitionService({
    required this.onResult,
    required this.onListeningStateChanged,
  });

  String get text => _text;
  String get currentImage => _currentImage;
  bool get isListening => _isListening;

  Future<void> initSpeech(BuildContext context) async {
    await _requestMicrophonePermission(context);
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) {
        print('onError: $val');
        if (val.errorMsg == 'aborted' || val.errorMsg == 'no match') {
          _resetListeningState(context);
        } else {
          _resetListeningState(context);

        }
      },
    );
    _speechRecognitionAvailable = available;
    if (!available) {
      _showErrorSnackBar(context, '음성 인식 기능을 사용할 수 없습니다. 권한을 확인해주세요.');
    } else {
      await Future.delayed(const Duration(seconds: 1));
      print("Speech recognition initialized and ready to use");
      listen(context);
    }
  }

  Future<void> _requestMicrophonePermission(BuildContext context) async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    if (!status.isGranted) {
      _showErrorSnackBar(context, '마이크 권한이 필요합니다.');
    }
  }

  void listen(BuildContext context) async {

    if (_speechRecognitionAvailable && !_isListening) {
      print("Starting to listen");
      _isListening = true;
      _text = "Listening...";
      onListeningStateChanged();
      _speech.listen(
        onResult: (val) {
          _text = val.recognizedWords.isEmpty ? "..." : val.recognizedWords;
          onListeningStateChanged();
          if (val.finalResult) {
            if (_text.length >= 3) { // 텍스트 길이 조건 추가
              onResult(_text);
              sendTextToFirestore(_text, "uid", "docId", "messageFieldName");
            }
            _resetListeningState(context);
          }
        },
        listenFor: const Duration(seconds: 180),
        pauseFor: const Duration(seconds: 6),
        partialResults: true,
        localeId: 'ko_KR',

      );
    } else if (_isListening) {
      print("Stopping listening");
      _isListening = false;
      _speech.stop();
      _showSnackBar(context, 'Recognized Text: $_text');
      onListeningStateChanged();
      Future.delayed(const Duration(seconds: 1), () => listen(context));
    }
  }


  void _resetListeningState(BuildContext context) {
    _isListening = false;
    _currentImage = 'assets/idle.png';
    _speech.stop();
    onListeningStateChanged();
    Future.delayed(const Duration(milliseconds: 50), () => listen(context)); // 음성인식을 재시작 할 때는 거의 즉시 일어나도록
  }

  Future<void> sendTextToFirestore(String text, String uid, String docId, String messageFieldName) async {
    try {
      await sendPromptToFirestore(
        uid: uid,
        text: text,
        docId: docId,
        messageFieldName: messageFieldName,
      );
      print("Text sent to Firestore: $text");
    } catch (e) {
      print("Error sending text to Firestore: $e");
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    _showSnackBar(context, message);
  }
}


