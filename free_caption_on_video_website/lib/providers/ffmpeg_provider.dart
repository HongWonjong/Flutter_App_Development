// providers/ffmpeg_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FfmpegState {
  final bool isInitialized;        // FFmpeg 초기화 완료
  final bool isFsReady;            // FS 모듈 준비 완료
  final bool isInputWritten;       // 입력 파일 쓰기 완료
  final bool isCommandExecuted;    // FFmpeg 명령어 실행 완료
  final bool isOutputRead;         // 출력 파일 읽기 완료
  final bool isAudioExtracted;     // 오디오 추출 전체 완료 (기존 상태 유지)

  FfmpegState({
    this.isInitialized = false,
    this.isFsReady = false,
    this.isInputWritten = false,
    this.isCommandExecuted = false,
    this.isOutputRead = false,
    this.isAudioExtracted = false,
  });

  FfmpegState copyWith({
    bool? isInitialized,
    bool? isFsReady,
    bool? isInputWritten,
    bool? isCommandExecuted,
    bool? isOutputRead,
    bool? isAudioExtracted,
  }) {
    return FfmpegState(
      isInitialized: isInitialized ?? this.isInitialized,
      isFsReady: isFsReady ?? this.isFsReady,
      isInputWritten: isInputWritten ?? this.isInputWritten,
      isCommandExecuted: isCommandExecuted ?? this.isCommandExecuted,
      isOutputRead: isOutputRead ?? this.isOutputRead,
      isAudioExtracted: isAudioExtracted ?? this.isAudioExtracted,
    );
  }
}

final ffmpegProvider = StateProvider<FfmpegState>((ref) => FfmpegState());