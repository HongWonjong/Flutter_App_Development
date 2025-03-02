import 'package:flutter_riverpod/flutter_riverpod.dart';

class WhisperState {
  final bool isRequesting;
  final bool isSrtGenerated;
  final String? requestError;
  final String? finalError;
  final bool hasErrorDisplayed;
  final double progress;
  final String? estimatedTime;
  final String? translation;  // 번역된 SRT
  final String? original;     // 원본 SRT (추가)
  final String transcriptionStatus;
  final int? audioSize;
  final int? responseStatusCode;

  WhisperState({
    this.isRequesting = false,
    this.isSrtGenerated = false,
    this.requestError,
    this.finalError,
    this.hasErrorDisplayed = false,
    this.progress = 0.0,
    this.estimatedTime,
    this.translation,
    this.original,            // 원본 SRT 필드 추가
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
    double? progress,
    String? estimatedTime,
    String? translation,
    String? original,         // copyWith에 추가
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
      original: original ?? this.original,  // 원본 SRT 반영
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
    String? original,         // update에 추가
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
      original: original,     // 원본 SRT 저장
      transcriptionStatus: transcriptionStatus,
      audioSize: audioSize,
      responseStatusCode: responseStatusCode,
    );
  }
}

final whisperProvider = StateNotifierProvider<WhisperNotifier, WhisperState>((ref) => WhisperNotifier());