// providers/ffmpeg_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FmpegState {
  final bool isInitialized;
  final bool isFsReady;
  final bool isInputWritten;
  final bool isCommandExecuted;
  final bool isOutputRead;
  final bool isAudioExtracted;
  final String? errorMessage;
  final bool hasErrorDisplayed;
  final int? audioFileSize; // 오디오 파일 용량 (바이트 단위)

  FmpegState({
    this.isInitialized = false,
    this.isFsReady = false,
    this.isInputWritten = false,
    this.isCommandExecuted = false,
    this.isOutputRead = false,
    this.isAudioExtracted = false,
    this.errorMessage,
    this.hasErrorDisplayed = false,
    this.audioFileSize,
  });

  FmpegState copyWith({
    bool? isInitialized,
    bool? isFsReady,
    bool? isInputWritten,
    bool? isCommandExecuted,
    bool? isOutputRead,
    bool? isAudioExtracted,
    String? errorMessage,
    bool? hasErrorDisplayed,
    int? audioFileSize,
  }) {
    return FmpegState(
      isInitialized: isInitialized ?? this.isInitialized,
      isFsReady: isFsReady ?? this.isFsReady,
      isInputWritten: isInputWritten ?? this.isInputWritten,
      isCommandExecuted: isCommandExecuted ?? this.isCommandExecuted,
      isOutputRead: isOutputRead ?? this.isOutputRead,
      isAudioExtracted: isAudioExtracted ?? this.isAudioExtracted,
      errorMessage: errorMessage ?? this.errorMessage,
      hasErrorDisplayed: hasErrorDisplayed ?? this.hasErrorDisplayed,
      audioFileSize: audioFileSize ?? this.audioFileSize,
    );
  }
}

final ffmpegProvider = StateProvider<FmpegState>((ref) => FmpegState());