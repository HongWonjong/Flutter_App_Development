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

  Future<String?> mergeMedia(List<File> imageFiles) async {
    final tempDir = await getTemporaryDirectory();
    final videoPath = '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';

    await FlutterQuickVideoEncoder.setup(
      width: 1920,
      height: 1080,
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

  Future<String?> mergeAllVideos(List<File> imageFiles, List<File> videoFiles) async {
    final imageVideoPath = await mergeMedia(imageFiles);
    final videoFilesWithImage = [...videoFiles];
    if (imageVideoPath != null) {
      videoFilesWithImage.add(File(imageVideoPath));
    }
    return await _videoMergingService.mergeAllVideos(videoFilesWithImage);
  }
}




