import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';

class VideoMergingService {
  // Standard resolution, codec, and fps for all videos
  final String targetResolution = '1080x1920';
  final String targetCodec = 'libx264'; // (H.264) codec로 통일
  final int targetFps = 30;

  // Re-encode video to HEVC (H.265) codec with standard resolution and fps
  Future<String?> _convertToHevc(File videoFile) async {
    final outputDir = await getTemporaryDirectory();
    final outputFilePath = '${outputDir.path}/converted_${videoFile.path.split('/').last}';

    // FFmpeg command to convert any video codec to HEVC (H.265)
    String command =
        '-i ${videoFile.path} -vf "scale=$targetResolution,fps=$targetFps" -c:v $targetCodec -preset fast -y $outputFilePath';

    print('Running FFmpeg command for converting to H.264: $command');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    final outputLogs = await session.getAllLogs();
    final failStackTrace = await session.getFailStackTrace();

    // Print FFmpeg logs for debugging
    for (Log log in outputLogs) {
      print('FFmpeg log: ${log.getMessage()}');
    }

    if (ReturnCode.isSuccess(returnCode)) {
      print('Video converted to H.264 successfully: $outputFilePath');
      return outputFilePath;
    } else {
      print('H.264 conversion failed: $failStackTrace');
      return null;
    }
  }

  // Merge all videos into a single HEVC (H.265) encoded file
  Future<String?> mergeAllVideos(List<File> videoFiles) async {
    List<String> hevcVideoPaths = [];

    // Convert all videos to HEVC (H.265) format
    for (File videoFile in videoFiles) {
      String? hevcVideoPath = await _convertToHevc(videoFile);
      if (hevcVideoPath != null) {
        hevcVideoPaths.add(hevcVideoPath);
      }
    }

    if (hevcVideoPaths.isNotEmpty) {
      final outputDir = await getTemporaryDirectory();
      final outputPath = '${outputDir.path}/merged_hevc_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // FFmpeg command to concatenate all HEVC videos
      String inputs = hevcVideoPaths.map((path) => '-i $path').join(' ');
      String command = '$inputs -filter_complex "concat=n=${hevcVideoPaths.length}:v=1:a=1" -c:v $targetCodec -preset fast -y $outputPath';

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
}

