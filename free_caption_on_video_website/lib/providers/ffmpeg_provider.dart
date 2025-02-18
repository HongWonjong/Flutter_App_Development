import 'package:flutter_riverpod/flutter_riverpod.dart';

class FfmpegState {
  final bool isAudioExtracted;

  FfmpegState({this.isAudioExtracted = false});

  FfmpegState copyWith({bool? isAudioExtracted}) {
    return FfmpegState(
      isAudioExtracted: isAudioExtracted ?? this.isAudioExtracted,
    );
  }
}

final ffmpegProvider = StateProvider<FfmpegState>((ref) {
  return FfmpegState();
});