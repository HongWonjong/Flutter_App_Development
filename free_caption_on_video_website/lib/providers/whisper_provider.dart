import 'package:flutter_riverpod/flutter_riverpod.dart';

final whisperProvider = StateProvider<WhisperState>((ref) => WhisperState());

class WhisperState {
  final bool isRequesting;
  final bool isSrtGenerated;
  final String? requestError;
  final String? finalError;
  final bool hasErrorDisplayed;
  final int progress;           // 진행률 (%)
  final String? estimatedTime;  // 예상 시간
  final String? translation;    // SRT 결과

  WhisperState({
    this.isRequesting = false,
    this.isSrtGenerated = false,
    this.requestError,
    this.finalError,
    this.hasErrorDisplayed = false,
    this.progress = 0,
    this.estimatedTime,
    this.translation,
  });

  WhisperState copyWith({
    bool? isRequesting,
    bool? isSrtGenerated,
    String? requestError,
    String? finalError,
    bool? hasErrorDisplayed,
    int? progress,
    String? estimatedTime,
    String? translation,
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
    );
  }
}