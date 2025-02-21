// services/ffmpeg_service.dart
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_caption_on_video_website/providers/ffmpeg_provider.dart';
import 'dart:js_util' as js_util;
import '../providers/audio_provider.dart';

@JS('FFmpeg.createFFmpeg')
external JSFunction get createFFmpeg;

@JS()
external JSObject get FFmpeg;

final ffmpegServiceProvider = Provider<FfmpegService>((ref) => FfmpegService(ref));

class FfmpegService {
  JSObject? _ffmpeg;
  bool _isInitialized = false;
  final Ref ref;

  FfmpegService(this.ref);

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final baseUrl = Uri.base.toString().endsWith('/') ? Uri.base.toString() : '${Uri.base.toString()}/';
      final corePath = '${baseUrl}ffmpeg-core.js';
      final workerPath = '${baseUrl}ffmpeg-core.worker.js';
      final options = <String, JSAny>{
        'log': true.toJS,
        'corePath': corePath.toJS,
        'workerPath': workerPath.toJS,
      }.jsify() as JSObject;
      _ffmpeg = createFFmpeg.callAsConstructor(options) as JSObject;
      final loadFn = _ffmpeg!.getProperty<JSFunction>('load'.toJS);
      final loadResult = loadFn.callAsFunction(_ffmpeg);
      if (loadResult != null) {
        await (loadResult as JSPromise).toDart;
        print('FFmpeg loaded successfully');
        await _waitForFSReady();
        _isInitialized = true;
        ref.read(ffmpegProvider.notifier).state = ref.read(ffmpegProvider).copyWith(isInitialized: true);
      } else {
        throw Exception('FFmpeg load returned null');
      }
    } catch (e) {
      print('Error initializing FFmpeg: $e');
      _isInitialized = false;
      ref.read(ffmpegProvider.notifier).state = ref.read(ffmpegProvider).copyWith(
        errorMessage: 'Initialize failed: $e',
        hasErrorDisplayed: true,
      );
      rethrow;
    }
  }

  Future<void> _waitForFSReady() async {
    const maxAttempts = 50;
    var attempts = 0;
    while (attempts < maxAttempts) {
      final fs = _ffmpeg!.getProperty<JSFunction>('FS'.toJS);
      if (fs != null) {
        ref.read(ffmpegProvider.notifier).state = ref.read(ffmpegProvider).copyWith(isFsReady: true);
        return;
      }
      await Future.delayed(Duration(milliseconds: 100));
      attempts++;
    }
    throw Exception('FS module not ready after $maxAttempts attempts');
  }

  Future<Uint8List?> extractAudio(Uint8List videoBytes) async {
    try {
      ref.read(ffmpegProvider.notifier).state = FmpegState(); // 상태 리셋
      print('FFmpeg state reset at start: ${ref.read(ffmpegProvider)}');

      await initialize();
      if (_ffmpeg == null || !_isInitialized) {
        print('FFmpeg instance is null or not initialized');
        ref.read(ffmpegProvider.notifier).state = ref.read(ffmpegProvider).copyWith(
          errorMessage: 'FFmpeg instance is null or not initialized',
          hasErrorDisplayed: true,
        );
        return null;
      }

      final fs = _ffmpeg!.getProperty<JSFunction>('FS'.toJS);
      if (fs == null) {
        print('FS module is null');
        ref.read(ffmpegProvider.notifier).state = ref.read(ffmpegProvider).copyWith(
          errorMessage: 'FS module not available',
          hasErrorDisplayed: true,
        );
        throw Exception('FS module not available');
      }

      fs.callAsFunction(_ffmpeg, 'writeFile'.toJS, 'input.mp4'.toJS, videoBytes.toJS);
      print('Input file written successfully');
      ref.read(ffmpegProvider.notifier).state = ref.read(ffmpegProvider).copyWith(isInputWritten: true);

      final args = ['-i', 'input.mp4', '-vn', '-acodec', 'libmp3lame', '-q:a', '2', '-y', 'output.mp3'];
      print('Running FFmpeg command with args: $args');
      final jsArgs = JSArray();
      for (var arg in args) {
        js_util.callMethod(jsArgs, 'push', [arg.toJS]);
      }
      print('jsArgs prepared: ${js_util.callMethod(jsArgs, 'toString', [])}');

      final runResult = js_util.callMethod(_ffmpeg!, 'run', jsArgs.toDart) as JSPromise;
      await runResult.toDart;
      print('FFmpeg command executed successfully');
      ref.read(ffmpegProvider.notifier).state = ref.read(ffmpegProvider).copyWith(isCommandExecuted: true);

      final readResult = fs.callAsFunction(_ffmpeg, 'readFile'.toJS, 'output.mp3'.toJS);
      if (readResult == null) {
        print('Failed to read output file: readResult is null');
        ref.read(ffmpegProvider.notifier).state = ref.read(ffmpegProvider).copyWith(
          errorMessage: 'FS.readFile returned null',
          hasErrorDisplayed: true,
        );
        throw Exception('FS.readFile returned null');
      }

      print('readResult type: ${readResult.runtimeType}');
      Uint8List audioData;
      if (readResult is JSUint8Array) {
        audioData = Uint8List.fromList(readResult.toDart);
      } else {
        print('Unexpected readResult type: ${readResult.runtimeType}');
        ref.read(ffmpegProvider.notifier).state = ref.read(ffmpegProvider).copyWith(
          errorMessage: 'Unexpected readResult type: ${readResult.runtimeType}',
          hasErrorDisplayed: true,
        );
        throw Exception('Unexpected readResult type');
      }

      print('Audio extraction completed, audioData length: ${audioData.length}');
      ref.read(ffmpegProvider.notifier).state = ref.read(ffmpegProvider).copyWith(
        isOutputRead: true,
        isAudioExtracted: true,
        errorMessage: null,
        hasErrorDisplayed: false,
        audioFileSize: audioData.length,
      );

      // 오디오 데이터를 audioProvider에 저장
      ref.read(audioProvider.notifier).state = audioData;

      return audioData;
    } catch (e) {
      print('Error in extractAudio: $e');
      ref.read(ffmpegProvider.notifier).state = ref.read(ffmpegProvider).copyWith(
        errorMessage: e.toString(),
        hasErrorDisplayed: true,
      );
      return null;
    }
  }

  void reset() {
    if (_ffmpeg != null) {
      _ffmpeg!.callMethod('exit'.toJS);
      _ffmpeg = null;
      _isInitialized = false;
      ref.read(ffmpegProvider.notifier).state = FmpegState();
      print('FFmpeg reset completed');
    }
  }

  void dispose() {
    reset();
  }
}