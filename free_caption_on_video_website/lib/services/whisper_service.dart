import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../providers/whisper_provider.dart';

final whisperServiceProvider = Provider<WhisperService>((ref) => WhisperService(ref));

class WhisperService {
  final Ref ref;

  WhisperService(this.ref);

  static const String _apiEndpoint = 'https://124.52.62.85:5000/translate'; // ✅ Flask 서버 IP 확인

  Stream<Map<String, dynamic>> transcribeAudioToSrt(Uint8List audioBytes, String sourceLanguage) async* {
    try {
      print("[INFO] 요청 시작: $_apiEndpoint");
      print("[INFO] 오디오 크기: ${audioBytes.length} bytes");
      print("[INFO] 언어 설정: ${_mapLanguageCode(sourceLanguage)}");

      ref.read(whisperProvider.notifier).state = ref.read(whisperProvider).copyWith(
        isRequesting: true,
        requestError: null,
        hasErrorDisplayed: false,
      );

      var request = http.MultipartRequest('POST', Uri.parse(_apiEndpoint))
        ..fields['language'] = _mapLanguageCode(sourceLanguage)
        ..files.add(
          http.MultipartFile.fromBytes(
            'audio',
            audioBytes,
            filename: 'audio.mp3',
          ),
        );

      print("[INFO] 요청 보냄...");

      var response = await request.send();
      print("[INFO] 서버 응답 상태 코드: ${response.statusCode}");

      if (response.statusCode != 200) {
        print("[ERROR] 요청 실패: 상태 코드 ${response.statusCode}");
        throw Exception("Failed to upload audio: ${response.reasonPhrase}");
      }

      var stream = response.stream.transform(utf8.decoder).transform(LineSplitter());

      await for (var line in stream) {
        print("[INFO] 서버 응답: $line");
        var data = jsonDecode(line);
        ref.read(whisperProvider.notifier).state = ref.read(whisperProvider).copyWith(
          isRequesting: data['status'] != 'completed',
          progress: data['progress'],
          estimatedTime: data['estimated_time'],
          translation: data['status'] == 'completed' ? data['translation'] : null,
          isSrtGenerated: data['status'] == 'completed',
        );
        yield data;
      }
    } catch (e) {
      ref.read(whisperProvider.notifier).state = ref.read(whisperProvider).copyWith(
        isRequesting: false,
        requestError: e.toString(),
        hasErrorDisplayed: true,
      );
      print("[ERROR] Whisper 요청 오류: $e");
      rethrow;
    }
  }

  String _mapLanguageCode(String language) {
    switch (language) {
      case '영어':
        return 'en';
      case '한국어':
        return 'ko';
      case '일본어':
        return 'ja';
      case '중국어':
        return 'zh';
      default:
        return 'en';
    }
  }
}
