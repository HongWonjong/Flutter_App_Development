import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

@JS('FFmpeg.createFFmpeg')
external JSFunction get createFFmpeg;

@JS()
external JSObject get FFmpeg;

class FfmpegService {
  JSObject? _ffmpeg;

  Future<void> initialize() async {
    if (_ffmpeg != null) return;

    print('Initializing FFmpeg...');
    final baseUrl = Uri.base.toString().endsWith('/') ? Uri.base.toString() : '${Uri.base.toString()}/';
    final corePath = '${baseUrl}ffmpeg-core.js';
    print('Setting corePath: $corePath');
    final options = <String, JSAny>{
      'log': true.toJS,
      'corePath': corePath.toJS,
    }.jsify() as JSObject;
    _ffmpeg = createFFmpeg.callAsConstructor(options) as JSObject;
    final loadFn = _ffmpeg!.getProperty<JSFunction>('load'.toJS);
    print('Calling FFmpeg.load()');
    final loadResult = loadFn.callAsFunction(_ffmpeg);
    if (loadResult != null) {
      try {
        await (loadResult as JSPromise).toDart;
        print('FFmpeg loaded successfully');
      } catch (e) {
        print('Error loading FFmpeg: $e');
        rethrow;
      }
    } else {
      print('Failed to get load result');
    }
  }

  Future<Uint8List?> extractAudio(Uint8List videoBytes) async {
    try {
      await initialize();
      if (_ffmpeg == null) {
        print('FFmpeg instance is null');
        return null;
      }

      final fs = _ffmpeg!.getProperty<JSFunction>('FS'.toJS);
      print('Writing input file to FS...');
      final writeResult = fs.callAsFunction(_ffmpeg, 'writeFile'.toJS, 'input.mp4'.toJS, videoBytes.toJS);
      if (writeResult != null) {
        await (writeResult as JSPromise).toDart;
      } else {
        print('Failed to write input file');
        return null;
      }

      final run = _ffmpeg!.getProperty<JSFunction>('run'.toJS);
      final args = ['-i', 'input.mp4', '-vn', '-acodec', 'mp3', 'output.mp3'].map((s) => s.toJS).toList().jsify();
      print('Running FFmpeg command: $args');
      final runResult = run.callAsFunction(_ffmpeg, args);
      if (runResult != null) {
        await (runResult as JSPromise).toDart;
      } else {
        print('Failed to run FFmpeg command');
        return null;
      }

      print('Reading output file...');
      final readResult = fs.callAsFunction(_ffmpeg, 'readFile'.toJS, 'output.mp3'.toJS);
      Uint8List? audioData;
      if (readResult != null) {
        audioData = await (readResult as JSPromise).toDart as Uint8List?;
      } else {
        print('Failed to read output file');
        return null;
      }

      print('Cleaning up FS...');
      final unlinkInput = fs.callAsFunction(_ffmpeg, 'unlink'.toJS, 'input.mp4'.toJS);
      if (unlinkInput != null) {
        await (unlinkInput as JSPromise).toDart;
      }
      final unlinkOutput = fs.callAsFunction(_ffmpeg, 'unlink'.toJS, 'output.mp3'.toJS);
      if (unlinkOutput != null) {
        await (unlinkOutput as JSPromise).toDart;
      }

      return audioData;
    } catch (e) {
      print('Error in extractAudio: $e');
      return null;
    }
  }

  void dispose() {
    if (_ffmpeg != null) {
      _ffmpeg!.callMethod('exit'.toJS);
      _ffmpeg = null;
    }
  }
}