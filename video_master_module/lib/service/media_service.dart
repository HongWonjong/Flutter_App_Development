import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'media_picking.dart';
import 'image_processing.dart';
import 'video_merging.dart';
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';

class MediaService {
  final MediaPickerService _mediaPickerService = MediaPickerService();
  final ImageProcessingService _imageProcessingService = ImageProcessingService();
  final VideoMergingService _videoMergingService = VideoMergingService();

  Future<List<File>> pickMedia(BuildContext context) async {
    return await _mediaPickerService.pickMedia(context);
  }

  // Helper method to check if the file is an image based on extension
  bool _isImageFile(File file) {
    final String extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'bmp', 'gif'].contains(extension);
  }

  // 이미지 파일을 비디오로 변환
  Future<String?> _processImagesToVideo(List<File> imageFiles) async {
    final tempDir = await getTemporaryDirectory();
    final videoPath = '${tempDir.path}/image_to_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

    await FlutterQuickVideoEncoder.setup(
      width: 1080,
      height: 1920,
      fps: 30,
      videoBitrate: 5000000,
      audioChannels: 2,
      audioBitrate: 128000,
      sampleRate: 44100,
      profileLevel: ProfileLevel.highAutoLevel,
      filepath: videoPath,
    );

    for (File imageFile in imageFiles) {
      await _imageProcessingService.processImage(imageFile);
    }

    await FlutterQuickVideoEncoder.finish();
    return videoPath;
  }

  // 이미지와 비디오를 순서대로 병합
  Future<String?> mergeAllMedia(List<File> mediaFiles) async {
    List<File> resultFiles = [];
    final tempDir = await getTemporaryDirectory();

    // 미디어 파일을 변환하면서 처리한 파일을 순서대로 resultFiles에 추가
    for (File mediaFile in mediaFiles) {
      if (_isImageFile(mediaFile)) {
        // 이미지일 경우 비디오로 변환 후 임시로 파일로 저장
        String? imageVideoPath = await _processImagesToVideo([mediaFile]);
        if (imageVideoPath != null) {
          resultFiles.add(File(imageVideoPath));  // 변환된 비디오를 순서에 맞게 추가
        }
      } else {
        // 비디오일 경우 그대로 추가
        resultFiles.add(mediaFile);
      }
    }

    // 최종적으로 모든 비디오 파일을 병합
    if (resultFiles.isNotEmpty) {
      String mergedVideoPath = '${tempDir.path}/merged_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      return await _videoMergingService.mergeAllVideos(resultFiles);
    }

    return null;  // 병합할 파일이 없을 경우 null 반환
  }
}





