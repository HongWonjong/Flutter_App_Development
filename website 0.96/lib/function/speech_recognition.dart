import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:website/function/send_voice_to_main_ai.dart';
import 'package:website/function/send_voice_to_assistant_ai.dart';

class SpeechRecognitionService {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Say something...";
  bool _speechRecognitionAvailable = false;
  final Function(String) onResult;
  final VoidCallback onListeningStateChanged;

  SpeechRecognitionService({
    required this.onResult,
    required this.onListeningStateChanged,
  });

  String get text => _text;
  bool get isListening => _isListening;

  Future<void> initSpeech(BuildContext context) async {
    await _requestMicrophonePermission(context);
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onStatus: (status) => {
        print('onStatus: $status'),
        if (status == 'done') { // notListening 은 내가 아무 말도 하지 않아서 자동 정지된 경우의 상태, done은 충분한 단어를 인식해서 listen(context)의 if문이 작동했을 경우의 상태
          listen(context)
        },
      },
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
      _resetListeningState(context);
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

      print("Starting to listen");
      _isListening = true;
      _text = "Listening...";
      onListeningStateChanged();
      _speech.listen(
        onResult: (val) {
          _text = val.recognizedWords.isEmpty ? "..." : val.recognizedWords;
          onListeningStateChanged();
          if (val.finalResult) {
            onResult(_text);
            _resetListeningState(context);
          }
        },
        listenFor: const Duration(seconds: 240),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: 'ko_KR',
      );
  }

  void _resetListeningState(BuildContext context) {
    _isListening = false;
    _speech.stop();
    onListeningStateChanged();

    // Check the state after a delay to ensure the previous listen has fully stopped
    Future.delayed(const Duration(milliseconds: 500), () { // 백그라운드로 프로그램이 가 있다가 다시 돌아왔을 때 무한루프를 방지하는 부분
      if (!_isListening && _speechRecognitionAvailable) {
        listen(context);
      }
    });
  }


  Future<void> sendTextToFirestore(String text, String uid, String docId, String messageFieldName) async {
    try {
      await sendPromptToFirestore( //메인ai에게 대화를 전달
        uid: uid,
        text: text,
        docId: docId,
        messageFieldName: messageFieldName,
      );
      await sendPromptToAssistantFirestore( //보조ai에게 대화를 전달
        uid: uid,
        text: text,
        docId: docId,
        commandFieldName: messageFieldName,
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


