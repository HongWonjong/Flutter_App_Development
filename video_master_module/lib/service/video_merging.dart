import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';

class VideoMergingService {
  // Standard resolution, codec, and fps for all videos
  final String targetResolution = '1920x1080';
  final String targetCodec = 'libx264'; // H.264 codec
  final int targetFps = 30;

  // Re-encode video to ensure consistent codec, resolution, and fps
  Future<String?> _reencodeVideo(File videoFile) async {
    final outputDir = await getTemporaryDirectory();
    final outputFilePath = '${outputDir.path}/reencoded_${videoFile.path.split('/').last}';

    // FFmpeg command to standardize resolution, codec, and fps
    String command =
        '-i ${videoFile.path} -vf "scale=$targetResolution,fps=$targetFps" -c:v $targetCodec -preset veryfast -y $outputFilePath';

    print('Running FFmpeg command for re-encoding: $command');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    final outputLogs = await session.getAllLogs();
    final failStackTrace = await session.getFailStackTrace();

    // Print all logs for debugging
    for (Log log in outputLogs) {
      print('FFmpeg log: ${log.getMessage()}');
    }

    if (ReturnCode.isSuccess(returnCode)) {
      print('Video re-encoded successfully: $outputFilePath');
      return outputFilePath;
    } else {
      print('Video re-encoding failed: $failStackTrace');
      return null;
    }
  }

  Future<String?> mergeAllVideos(List<File> videoFiles) async {
    List<String> reencodedVideoPaths = [];

    // Re-encode all video files
    for (File videoFile in videoFiles) {
      String? reencodedVideoPath = await _reencodeVideo(videoFile);
      if (reencodedVideoPath != null) {
        reencodedVideoPaths.add(reencodedVideoPath);
      }
    }

    if (reencodedVideoPaths.isNotEmpty) {
      final outputDir = await getTemporaryDirectory();
      final outputPath = '${outputDir.path}/merged_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Concatenate all re-encoded videos using FFmpeg
      String inputs = reencodedVideoPaths.map((path) => '-i $path').join(' ');
      String command = '$inputs -filter_complex "concat=n=${reencodedVideoPaths.length}:v=1:a=1" -c:v $targetCodec -preset veryfast -y $outputPath';

      print('Running FFmpeg command for merging: $command');

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      final outputLogs = await session.getAllLogs();
      final failStackTrace = await session.getFailStackTrace();

      // Print all logs for debugging
      for (Log log in outputLogs) {
        print('FFmpeg log: ${log.getMessage()}');
      }

      if (ReturnCode.isSuccess(returnCode)) {
        print('Videos merged successfully: $outputPath');
        return outputPath;
      } else {
        print('Video merging failed: $failStackTrace');
        return null;
      }
    }

    return null;
  }
}


