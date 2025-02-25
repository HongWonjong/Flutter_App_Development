import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../providers/whisper_provider.dart';

final whisperServiceProvider = Provider<WhisperService>((ref) => WhisperService(ref));

class WhisperService {
  final Ref ref;

  WhisperService(this.ref);

  static const String _externalEndpoint = 'https://hongsreboratory123563122123.xyz/srt';

  Stream<Map<String, dynamic>> transcribeAudioToSrt(Uint8List audioBytes, String sourceLanguage) async* {
    try {
      print("[INFO] 요청 시작: $_externalEndpoint");

      // 요청 시작 전 상태 업데이트
      ref.read(whisperProvider.notifier).state = ref.read(whisperProvider).copyWith(
        isRequesting: true,
        transcriptionStatus: 'requestSent',
      );

      var request = http.MultipartRequest('POST', Uri.parse(_externalEndpoint))
        ..fields['language'] = sourceLanguage
        ..files.add(http.MultipartFile.fromBytes('audio', audioBytes, filename: 'audio.mp3'));

      print("[INFO] 요청 보냄...");
      final response = await http.Client().send(request).timeout(Duration(seconds: 60));
      print("[INFO] 서버 응답 상태 코드: ${response.statusCode}");

      // 요청 전송 후 1초 대기 후 성공 판단
      await Future.delayed(Duration(seconds: 1));
      if (response.statusCode == 200) {
        print("[INFO] 요청이 1초 후에도 문제없음, 성공으로 간주");
        ref.read(whisperProvider.notifier).state = ref.read(whisperProvider).copyWith(
          isRequesting: true, // 아직 처리 중이니까 true 유지
          transcriptionStatus: 'processing', // 성공적으로 전송됨
        );
      } else {
        final errorMsg = "요청 실패: ${response.reasonPhrase} (Status: ${response.statusCode})";
        print("[ERROR] $errorMsg");
        ref.read(whisperProvider.notifier).state = ref.read(whisperProvider).copyWith(
          isRequesting: false,
          requestError: errorMsg,
          transcriptionStatus: 'error',
        );
        yield {'status': 'error', 'message': errorMsg};
        return;
      }

      // 스트림을 한 번만 구독
      await for (var line in response.stream.transform(utf8.decoder).transform(LineSplitter())) {
        print("[INFO] 서버 응답 줄: $line");
        var data = jsonDecode(line);
        ref.read(whisperProvider.notifier).state = ref.read(whisperProvider).copyWith(
          isRequesting: data['status'] != 'completed' && data['status'] != 'error',
          progress: data['progress'],
          estimatedTime: data['estimated_time'],
          transcriptionStatus: data['status'],
          translation: data['status'] == 'completed' ? data['translation'] : null, // 추가
        );
        yield data;
      }
    } catch (e) {
      final errorMsg = "요청 오류: $e";
      print("[ERROR] $errorMsg");
      ref.read(whisperProvider.notifier).state = ref.read(whisperProvider).copyWith(
        isRequesting: false,
        requestError: errorMsg,
        transcriptionStatus: 'error',
      );
      yield {'status': 'error', 'message': errorMsg};
    }
  }
}