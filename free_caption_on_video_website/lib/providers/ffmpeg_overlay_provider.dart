import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FmpegOverlayState {
  final bool isInitialized;
  final bool isProcessing;
  final bool isOverlayComplete;
  final String? errorMessage;
  final bool hasErrorDisplayed;
  final double progress;
  final Uint8List? videoData;

  FmpegOverlayState({
    this.isInitialized = false,
    this.isProcessing = false,
    this.isOverlayComplete = false,
    this.errorMessage,
    this.hasErrorDisplayed = false,
    this.progress = 0.0,
    this.videoData,
  });

  FmpegOverlayState copyWith({
    bool? isInitialized,
    bool? isProcessing,
    bool? isOverlayComplete,
    String? errorMessage,
    bool? hasErrorDisplayed,
    double? progress,
    Uint8List? videoData,
  }) {
    return FmpegOverlayState(
      isInitialized: isInitialized ?? this.isInitialized,
      isProcessing: isProcessing ?? this.isProcessing,
      isOverlayComplete: isOverlayComplete ?? this.isOverlayComplete,
      errorMessage: errorMessage ?? this.errorMessage,
      hasErrorDisplayed: hasErrorDisplayed ?? this.hasErrorDisplayed,
      progress: progress ?? this.progress,
      videoData: videoData ?? this.videoData,
    );
  }
}

class FmpegOverlayNotifier extends StateNotifier<FmpegOverlayState> {
  FmpegOverlayNotifier() : super(FmpegOverlayState());

  void update({
    bool? isInitialized,
    bool? isProcessing,
    bool? isOverlayComplete,
    String? errorMessage,
    bool? hasErrorDisplayed,
    double? progress,
    Uint8List? videoData,
  }) {
    state = state.copyWith(
      isInitialized: isInitialized,
      isProcessing: isProcessing,
      isOverlayComplete: isOverlayComplete,
      errorMessage: errorMessage,
      hasErrorDisplayed: hasErrorDisplayed,
      progress: progress,
      videoData: videoData,
    );
  }
}

final ffmpegOverlayProvider = StateNotifierProvider<FmpegOverlayNotifier, FmpegOverlayState>((ref) => FmpegOverlayNotifier());