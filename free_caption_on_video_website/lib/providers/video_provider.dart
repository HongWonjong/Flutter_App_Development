import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_caption_on_video_website/services/ffmpeg_overlay_service.dart';
import 'package:free_caption_on_video_website/services/indexdb_service.dart';

class VideoState {
  final int? videoKey;
  final bool isUploaded;
  final int? videoFileSize;
  final Uint8List? thumbnail;

  VideoState({
    this.videoKey,
    this.isUploaded = false,
    this.videoFileSize,
    this.thumbnail,
  });

  VideoState copyWith({
    int? videoKey,
    bool? isUploaded,
    int? videoFileSize,
    Uint8List? thumbnail,
  }) {
    return VideoState(
      videoKey: videoKey ?? this.videoKey,
      isUploaded: isUploaded ?? this.isUploaded,
      videoFileSize: videoFileSize ?? this.videoFileSize,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}

class VideoNotifier extends StateNotifier<VideoState> {
  final Ref ref;

  VideoNotifier(this.ref) : super(VideoState());

  Future<void> uploadVideo(Uint8List videoBytes) async {
    debugPrint('VideoNotifier.uploadVideo 호출: 비디오 크기 ${videoBytes.length} bytes');
    final indexedDbService = ref.read(indexedDbServiceProvider);

    try {
      debugPrint('IndexedDB에 비디오 저장 시작');
      final videoKey = await indexedDbService.saveVideo(videoBytes);
      debugPrint('비디오 저장 완료: videoKey = $videoKey');

      state = state.copyWith(
        videoKey: videoKey,
        isUploaded: true,
        videoFileSize: videoBytes.length,
      );
      debugPrint('비디오 업로드 상태 업데이트 완료: videoKey = ${state.videoKey}');

      await captureThumbnail(); // 업로드 후 썸네일 캡처
    } catch (e) {
      debugPrint('비디오 업로드 실패: $e');
      rethrow;
    }
  }

  Future<void> captureThumbnail() async {
    debugPrint('VideoNotifier.captureThumbnail 호출');
    final indexedDbService = ref.read(indexedDbServiceProvider);
    final ffmpegService = ref.read(ffmpegOverlayServiceProvider);

    if (state.videoKey == null) {
      debugPrint('캡처 실패: videoKey가 null입니다');
      return;
    }

    try {
      debugPrint('IndexedDB에서 비디오 데이터 가져오기: videoKey = ${state.videoKey}');
      final videoBytes = await indexedDbService.getVideo(state.videoKey!);
      if (videoBytes == null) {
        debugPrint('캡처 실패: 비디오 데이터가 null입니다');
        return;
      }

      debugPrint('1초 시점 프레임 추출 시작');
      final thumbnail = await ffmpegService.captureFrame(videoBytes, time: 1.0);
      if (thumbnail == null || thumbnail.isEmpty) {
        debugPrint('썸네일 추출 실패: thumbnail is null or empty');
      } else {
        debugPrint('썸네일 추출 성공: ${thumbnail.length} bytes');
      }

      state = state.copyWith(
        thumbnail: thumbnail != null && thumbnail.isNotEmpty
            ? thumbnail
            : Uint8List.fromList([0, 0, 0, 255]), // 기본 이미지
      );
      debugPrint('썸네일 상태 업데이트 완료: thumbnail ${state.thumbnail!.length} bytes');
    } catch (e) {
      debugPrint('썸네일 캡처 실패: $e');
      state = state.copyWith(thumbnail: Uint8List.fromList([0, 0, 0, 255]));
    }
  }

  void reset() {
    state = VideoState();
    debugPrint('비디오 상태 초기화');
  }
}

final videoProvider = StateNotifierProvider<VideoNotifier, VideoState>((ref) {
  return VideoNotifier(ref);
});

final indexedDbServiceProvider = Provider<IndexedDbService>((ref) => IndexedDbService());