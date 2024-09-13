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

  Future<String?> mergeMedia(List<File> mediaFiles) async {
    final tempDir = await getTemporaryDirectory();
    final videoPath = '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';

    List<File> imageFiles = [];
    List<File> videoFiles = [];

    // Separate image and video files based on their extensions
    for (File mediaFile in mediaFiles) {
      if (_isImageFile(mediaFile)) {
        imageFiles.add(mediaFile);
      } else {
        videoFiles.add(mediaFile);
      }
    }

    // Process images and convert them to video
    if (imageFiles.isNotEmpty) {
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
    }

    return videoPath;
  }

  Future<String?> mergeAllVideos(List<File> mediaFiles) async {
    // Separate image files and video files
    List<File> imageFiles = [];
    List<File> videoFiles = [];

    for (File mediaFile in mediaFiles) {
      if (_isImageFile(mediaFile)) {
        imageFiles.add(mediaFile);
      } else {
        videoFiles.add(mediaFile);
      }
    }

    // If there are images, merge them into a video
    String? imageVideoPath;
    if (imageFiles.isNotEmpty) {
      imageVideoPath = await mergeMedia(imageFiles);
    }

    // Add the resulting image video to the list of video files if it exists
    if (imageVideoPath != null) {
      videoFiles.add(File(imageVideoPath));
    }

    // Now merge all the video files together
    return await _videoMergingService.mergeAllVideos(videoFiles);
  }
}




