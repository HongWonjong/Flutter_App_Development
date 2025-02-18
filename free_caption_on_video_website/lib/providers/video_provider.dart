import 'package:flutter_riverpod/flutter_riverpod.dart';

// 비디오 상태를 저장하는 클래스
class VideoState {
  final int? videoKey; // IndexedDB 키
  final bool isUploaded; // 업로드 여부

  VideoState({this.videoKey, this.isUploaded = false});

  VideoState copyWith({int? videoKey, bool? isUploaded}) {
    return VideoState(
      videoKey: videoKey ?? this.videoKey,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }
}

// 비디오 상태를 관리하는 StateProvider
final videoProvider = StateProvider<VideoState>((ref) {
  return VideoState(videoKey: null, isUploaded: false);
});