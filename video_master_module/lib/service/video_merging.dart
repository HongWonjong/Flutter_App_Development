import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class VideoMergingService {
  final String targetResolution = '1080x1920';
  final int targetFps = 30;

  // Helper method to get the appropriate codec for the current platform
  String getCodec() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'h264_videotoolbox'; // iOS uses VideoToolbox
    } else {
      return 'libx264'; // Other platforms use libx264
    }
  }

  // Re-encode video to (H.264) codec with standard resolution and fps
  Future<String?> _convertToH264(File videoFile) async {
    final outputDir = await getTemporaryDirectory();
    final outputFilePath = '${outputDir.path}/converted_${videoFile.path.split('/').last}';

    String codec = getCodec();

    // FFmpeg command to convert video codec to the appropriate H.264 codec
    String command =
        '-i ${videoFile.path} -vf "scale=w=1080:h=1920:force_original_aspect_ratio=increase,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,fps=$targetFps" -c:v $codec -y $outputFilePath';

    print('Running FFmpeg command for converting to $codec: $command');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    final outputLogs = await session.getAllLogs();
    final failStackTrace = await session.getFailStackTrace();

    // Log FFmpeg output to a file for debugging
    final logFile = File('${outputDir.path}/ffmpeg_log_${DateTime.now().millisecondsSinceEpoch}.txt');
    for (Log log in outputLogs) {
      await logFile.writeAsString('${log.getMessage()}\n', mode: FileMode.append);
    }

    if (returnCode != null && ReturnCode.isSuccess(returnCode)) {
      print('Video converted to H.264 successfully: $outputFilePath');
      return outputFilePath;
    } else {
      print('H.264 conversion failed: $failStackTrace');
      return null;
    }
  }

// Add silent audio track to a video file if it doesn't have an audio stream
  Future<String?> _addSilentAudio(File videoFile) async {
    final outputDir = await getTemporaryDirectory();
    final outputFilePath = '${outputDir.path}/silent_${videoFile.path.split('/').last}';

    // FFmpeg command to add silent audio to a video
    String command = '-i ${videoFile.path} -f lavfi -t 1 -i anullsrc=r=44100:cl=stereo '
        '-shortest -c:v copy -c:a aac -strict experimental $outputFilePath';

    print('Running FFmpeg command to add silent audio: $command');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    final outputLogs = await session.getAllLogs();
    final failStackTrace = await session.getFailStackTrace();

    // Log FFmpeg output to a file for debugging
    final logFile = File('${outputDir.path}/ffmpeg_log_${DateTime.now().millisecondsSinceEpoch}.txt');
    for (Log log in outputLogs) {
      await logFile.writeAsString('${log.getMessage()}\n', mode: FileMode.append);
    }

    if (returnCode != null && ReturnCode.isSuccess(returnCode)) {
      print('Silent audio added successfully: $outputFilePath');
      return outputFilePath;
    } else {
      print('Failed to add silent audio: $failStackTrace');
      return null;
    }
  }

// Merge all videos into a single (H.264) encoded file
  Future<String?> mergeAllVideos(List<File> videoFiles) async {
    List<String> h264VideoPaths = [];

    // Convert all videos to (H.264) format and ensure they have an audio track
    for (File videoFile in videoFiles) {
      String? h264VideoPath = await _convertToH264(videoFile);

      // If the video has no audio, add silent audio track
      bool hasAudio = await _checkIfVideoHasAudio(h264VideoPath);
      if (!hasAudio) {
        h264VideoPath = await _addSilentAudio(File(h264VideoPath!));
      }

      if (h264VideoPath != null) {
        h264VideoPaths.add(h264VideoPath);
      }
    }

    if (h264VideoPaths.isNotEmpty) {
      final outputDir = await getTemporaryDirectory();
      final outputPath = '${outputDir.path}/merged_h264_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // FFmpeg command to concatenate all (H.264) videos
      String inputs = h264VideoPaths.map((path) => '-i $path').join(' ');
      String command = '$inputs -filter_complex "concat=n=${h264VideoPaths.length}:v=1:a=1" -c:v h264_videotoolbox -y $outputPath';

      print('Running FFmpeg command for merging H.264 videos: $command');

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      final outputLogs = await session.getAllLogs();
      final failStackTrace = await session.getFailStackTrace();

      // Print FFmpeg logs for debugging
      for (Log log in outputLogs) {
        print('FFmpeg log: ${log.getMessage()}');
      }

      if (ReturnCode.isSuccess(returnCode)) {
        print('H.264 videos merged successfully: $outputPath');
        return outputPath;
      } else {
        print('H.264 video merging failed: $failStackTrace');
        return null;
      }
    }

    return null;
  }

// Function to check if video has audio
  Future<bool> _checkIfVideoHasAudio(String? videoPath) async {
    if (videoPath == null) return false;

    final session = await FFmpegKit.execute('-i $videoPath -hide_banner');
    final logs = await session.getAllLogs();
    for (Log log in logs) {
      if (log.getMessage().contains('Audio:')) {
        return true; // Video has an audio stream
      }
    }
    return false; // No audio stream found
  }


}



