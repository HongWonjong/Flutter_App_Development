import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:js_util' as js_util;

import '../providers/ffmpeg_overlay_provider.dart';

@JS('FFmpeg.createFFmpeg')
external JSFunction get createFFmpeg;

@JS()
external JSObject get FFmpeg;

final ffmpegOverlayServiceProvider = Provider<FmpegOverlayService>((ref) => FmpegOverlayService(ref));

class FmpegOverlayService {
  JSObject? _ffmpeg;
  bool _isInitialized = false;
  final Ref ref;

  FmpegOverlayService(this.ref);

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('FFmpeg 이미 초기화됨');
      return;
    }

    try {
      final baseUrl = Uri.base.toString().endsWith('/') ? Uri.base.toString() : '${Uri.base.toString()}/';
      debugPrint('FFmpeg 초기화 시작: baseUrl = $baseUrl');
      _ffmpeg = createFFmpeg.callAsConstructor(<String, JSAny>{
        'log': true.toJS,
        'corePath': '${baseUrl}ffmpeg-core.js'.toJS,
        'workerPath': '${baseUrl}ffmpeg-core.worker.js'.toJS,
      }.jsify() as JSObject) as JSObject;
      await (js_util.callMethod(_ffmpeg!, 'load', []) as JSPromise).toDart;
      _isInitialized = true;
      ref.read(ffmpegOverlayProvider.notifier).update(isInitialized: true);
      debugPrint('FFmpeg Overlay 초기화 성공');
    } catch (e) {
      ref.read(ffmpegOverlayProvider.notifier).update(
        errorMessage: 'FFmpeg 초기화 실패: $e',
        hasErrorDisplayed: true,
      );
      debugPrint('FFmpeg 초기화 오류: $e');
      rethrow;
    }
  }

  Future<Uint8List?> overlaySrtOnVideo(Uint8List videoBytes, String srtContent, Map<String, dynamic> style) async {
    try {
      ref.read(ffmpegOverlayProvider.notifier).update(isProcessing: true);
      await initialize();
      if (_ffmpeg == null || !_isInitialized) {
        throw Exception('FFmpeg Overlay not initialized');
      }

      final fs = _ffmpeg!.getProperty<JSFunction>('FS'.toJS);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final inputFile = 'input_$timestamp.mp4';
      final outputFile = 'output_$timestamp.mp4';

      debugPrint('FS에 $inputFile 쓰기 시작');
      fs.callAsFunction(_ffmpeg, 'writeFile'.toJS, inputFile.toJS, videoBytes.toJS);
      fs.callAsFunction(_ffmpeg, 'writeFile'.toJS, 'subtitles.srt'.toJS, srtContent.toJS);

      final assContent = _srtToAss(srtContent, style);
      fs.callAsFunction(_ffmpeg, 'writeFile'.toJS, 'subtitles.ass'.toJS, assContent.toJS);

      final args = [
        '-i', '"$inputFile"',
        '-vf', 'ass=subtitles.ass',
        '-c:a', 'copy',
        '-y', '"$outputFile"'
      ];
      final jsArgs = JSArray();
      args.forEach((arg) => js_util.callMethod(jsArgs, 'push', [arg.toJS]));
      debugPrint('FFmpeg run 호출: args = $args');
      await js_util.callMethod(_ffmpeg!, 'run', jsArgs.toDart) as JSPromise;
      debugPrint('FFmpeg run 완료');

      final outputData = fs.callAsFunction(_ffmpeg, 'readFile'.toJS, outputFile.toJS);
      if (outputData == null) {
        debugPrint('출력 데이터 읽기 실패: $outputFile가 생성되지 않았거나 읽을 수 없음');
        throw Exception('Failed to read output video');
      }

      final videoData = outputData is JSUint8Array
          ? Uint8List.fromList(outputData.toDart)
          : Uint8List.fromList(js_util.dartify(outputData) as List<int>);
      debugPrint('자막 오버레이 성공: ${videoData.length} bytes');

      fs.callAsFunction(_ffmpeg, 'unlink'.toJS, inputFile.toJS);
      fs.callAsFunction(_ffmpeg, 'unlink'.toJS, 'subtitles.srt'.toJS);
      fs.callAsFunction(_ffmpeg, 'unlink'.toJS, 'subtitles.ass'.toJS);
      fs.callAsFunction(_ffmpeg, 'unlink'.toJS, outputFile.toJS);

      ref.read(ffmpegOverlayProvider.notifier).update(
        isProcessing: false,
        isOverlayComplete: true,
        videoData: videoData,
      );
      return videoData;
    } catch (e) {
      ref.read(ffmpegOverlayProvider.notifier).update(
        isProcessing: false,
        errorMessage: 'Overlay failed: $e',
        hasErrorDisplayed: true,
      );
      debugPrint('Overlay 오류: $e');
      return null;
    }
  }

  Future<Uint8List?> captureFrame(Uint8List videoBytes, {double time = 1.0}) async {
    try {
      debugPrint('captureFrame 호출: time = $time, videoBytes = ${videoBytes.length} bytes');
      await initialize();
      if (_ffmpeg == null || !_isInitialized) {
        throw Exception('FFmpeg Overlay not initialized');
      }

      final fs = _ffmpeg!.getProperty<JSFunction>('FS'.toJS);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final inputFile = 'input_$timestamp.mp4';
      final outputFile = 'frame_$timestamp.jpg';

      debugPrint('FS에 $inputFile 쓰기 시작');
      fs.callAsFunction(_ffmpeg, 'writeFile'.toJS, inputFile.toJS, videoBytes.toJS);
      debugPrint('FS에 $inputFile 쓰기 완료');

      final args = [
        '-ss', '$time',  // -ss를 앞으로 이동
        '-i', '$inputFile',
        '-vframes', '1',
        '-q:v', '2',
        '-f', 'image2',
        '-y', '$outputFile'
      ];

      final jsArgs = JSArray();
      args.forEach((arg) => js_util.callMethod(jsArgs, 'push', [arg.toJS]));
      debugPrint('FFmpeg run 호출: args = $args');

      // FFmpeg 실행 및 종료 대기
      final runResult = await js_util.callMethod(_ffmpeg!, 'run', jsArgs.toDart) as JSPromise;
      await runResult.toDart;
      debugPrint('FFmpeg run 실행 완료');

      // FS 상태 확인
      final dirContents = js_util.callMethod(_ffmpeg!, 'FS', ['readdir', '/']);
      debugPrint('FS 디렉토리 상태: $dirContents');

      final frameData = fs.callAsFunction(_ffmpeg, 'readFile'.toJS, outputFile.toJS);
      if (frameData == null) {
        debugPrint('프레임 데이터 읽기 실패: $outputFile가 생성되지 않았거나 읽을 수 없음');
        throw Exception('Failed to capture frame: $outputFile not found');
      }

      final result = frameData is JSUint8Array
          ? Uint8List.fromList(frameData.toDart)
          : Uint8List.fromList(js_util.dartify(frameData) as List<int>);
      debugPrint('프레임 추출 성공: ${result.length} bytes');

      if (result.isEmpty) {
        debugPrint('추출된 프레임 데이터가 비어 있음');
        throw Exception('Captured frame data is empty');
      }

      // 파일 정리
      fs.callAsFunction(_ffmpeg, 'unlink'.toJS, inputFile.toJS);
      fs.callAsFunction(_ffmpeg, 'unlink'.toJS, outputFile.toJS);

      return result;
    } catch (e) {
      debugPrint('captureFrame 오류: $e');
      return Uint8List.fromList([0, 0, 0, 255]); // 기본 이미지
    }
  }

  String _srtToAss(String srtContent, Map<String, dynamic> style) {
    return '''
[Script Info]
Title: Custom Subtitles
ScriptType: v4.00+

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, BackColour, Bold, Italic, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,${style['fontFamily']},${style['fontSize']},${_colorToAss(style['textColor'])},${_colorToAss(style['bgColor'])},0,0,1,2,2,2,10,10,10,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
${_srtToEvents(srtContent)}
    ''';
  }

  String _colorToAss(Color color) => '&H${color.value.toRadixString(16).padLeft(8, '0')}';

  String _srtToEvents(String srtContent) {
    return 'Dialogue: 0,0:00:00.00,0:00:03.62,Default,,0,0,0,,${srtContent.split('\n')[4]}';
  }
}