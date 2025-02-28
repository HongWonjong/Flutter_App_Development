import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../providers/whisper_provider.dart';

// WhisperService 제공자 정의
final whisperServiceProvider = Provider<WhisperService>((ref) => WhisperService(ref));

class WhisperService {
  final Ref ref;

  WhisperService(this.ref);

  static const String _externalEndpoint = 'https://hongsreboratory123563122123.xyz/srt';

  Stream<Map<String, dynamic>> transcribeAudioToSrt(Uint8List audioBytes, String sourceLanguage) async* {
    try {
      print("[INFO] 요청 시작");

      // 오디오 파일 크기 계산 (MB 단위)
      final audioSizeMB = audioBytes.length / (1024 * 1024);
      // 예상 시간 계산 (초 단위)
      final estimatedTimeSeconds = (audioSizeMB * 12.73).round();
      final estimatedTime = '${estimatedTimeSeconds}s';

      // 상태 업데이트 (예상 시간 포함)
      ref.read(whisperProvider.notifier).update(
        isRequesting: true,
        transcriptionStatus: 'processing',
        estimatedTime: estimatedTime,
      );

      var request = http.MultipartRequest('POST', Uri.parse(_externalEndpoint))
        ..fields['language'] = sourceLanguage
        ..files.add(http.MultipartFile.fromBytes('audio', audioBytes, filename: 'audio.mp3'));

      print("[INFO] 요청 보냄...");
      final response = await http.Client().send(request).timeout(Duration(seconds: 60));

      if (response.statusCode != 200) {
        final errorMsg = "요청 실패: ${response.statusCode}";
        ref.read(whisperProvider.notifier).update(
          isRequesting: false,
          requestError: errorMsg,
          transcriptionStatus: 'error',
        );
        yield {'status': 'error', 'message': errorMsg};
        return;
      }

      await for (var line in response.stream.transform(utf8.decoder).transform(LineSplitter())) {
        var data = jsonDecode(line);
        if (data['status'] == 'completed') {
          ref.read(whisperProvider.notifier).update(
            isRequesting: false,
            transcriptionStatus: 'completed',
            translation: data['translation'],
            estimatedTime: '변환 완료', // 작업 완료 시 0으로 설정
          );
        }
        yield data;
      }
    } catch (e) {
      final errorMsg = "요청 오류: $e";
      ref.read(whisperProvider.notifier).update(
        isRequesting: false,
        requestError: errorMsg,
        transcriptionStatus: 'error',
      );
      yield {'status': 'error', 'message': errorMsg};
    }
  }
}