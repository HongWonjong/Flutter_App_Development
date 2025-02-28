import 'package:flutter_riverpod/flutter_riverpod.dart';

class WhisperState {
  final bool isRequesting;
  final bool isSrtGenerated;
  final String? requestError;
  final String? finalError;
  final bool hasErrorDisplayed;
  final double progress; // int -> double로 변경
  final String? estimatedTime;
  final String? translation;
  final String transcriptionStatus;
  final int? audioSize;
  final int? responseStatusCode;

  WhisperState({
    this.isRequesting = false,
    this.isSrtGenerated = false,
    this.requestError,
    this.finalError,
    this.hasErrorDisplayed = false,
    this.progress = 0.0, // 기본값 0 -> 0.0
    this.estimatedTime,
    this.translation,
    this.transcriptionStatus = 'notStarted',
    this.audioSize,
    this.responseStatusCode,
  });

  WhisperState copyWith({
    bool? isRequesting,
    bool? isSrtGenerated,
    String? requestError,
    String? finalError,
    bool? hasErrorDisplayed,
    double? progress, // int -> double
    String? estimatedTime,
    String? translation,
    String? transcriptionStatus,
    int? audioSize,
    int? responseStatusCode,
  }) {
    return WhisperState(
      isRequesting: isRequesting ?? this.isRequesting,
      isSrtGenerated: isSrtGenerated ?? this.isSrtGenerated,
      requestError: requestError ?? this.requestError,
      finalError: finalError ?? this.finalError,
      hasErrorDisplayed: hasErrorDisplayed ?? this.hasErrorDisplayed,
      progress: progress ?? this.progress,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      translation: translation ?? this.translation,
      transcriptionStatus: transcriptionStatus ?? this.transcriptionStatus,
      audioSize: audioSize ?? this.audioSize,
      responseStatusCode: responseStatusCode ?? this.responseStatusCode,
    );
  }
}

class WhisperNotifier extends StateNotifier<WhisperState> {
  WhisperNotifier() : super(WhisperState());

  void update({
    bool? isRequesting,
    bool? isSrtGenerated,
    String? requestError,
    String? finalError,
    bool? hasErrorDisplayed,
    double? progress,
    String? estimatedTime,
    String? translation,
    String? transcriptionStatus,
    int? audioSize,
    int? responseStatusCode,
  }) {
    state = state.copyWith(
      isRequesting: isRequesting,
      isSrtGenerated: isSrtGenerated,
      requestError: requestError,
      finalError: finalError,
      hasErrorDisplayed: hasErrorDisplayed,
      progress: progress,
      estimatedTime: estimatedTime,
      translation: translation,
      transcriptionStatus: transcriptionStatus,
      audioSize: audioSize,
      responseStatusCode: responseStatusCode,
    );
  }
}

final whisperProvider = StateNotifierProvider<WhisperNotifier, WhisperState>((ref) => WhisperNotifier());