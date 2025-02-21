// providers/video_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 비디오 상태를 저장하는 클래스
class VideoState {
  final int? videoKey; // IndexedDB 키
  final bool isUploaded; // 업로드 여부
  final int? videoFileSize; // 비디오 파일 용량 (바이트 단위)

  VideoState({
    this.videoKey,
    this.isUploaded = false,
    this.videoFileSize,
  });

  VideoState copyWith({
    int? videoKey,
    bool? isUploaded,
    int? videoFileSize,
  }) {
    return VideoState(
      videoKey: videoKey ?? this.videoKey,
      isUploaded: isUploaded ?? this.isUploaded,
      videoFileSize: videoFileSize ?? this.videoFileSize,
    );
  }
}

// 비디오 상태를 관리하는 StateProvider
final videoProvider = StateProvider<VideoState>((ref) {
  return VideoState(videoKey: null, isUploaded: false, videoFileSize: null);
});