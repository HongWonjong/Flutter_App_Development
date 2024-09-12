import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';

class VideoMergingService {
  Future<String?> mergeAllVideos(List<File> videoFiles) async {
    final videoPaths = videoFiles.map((file) => file.path).toList();
    final outputDir = await getTemporaryDirectory();
    final outputPath = '${outputDir.path}/merged_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

    if (videoPaths.isNotEmpty) {
      String inputs = videoPaths.map((path) => '-i $path').join(' ');
      String command = '$inputs -filter_complex "concat=n=${videoPaths.length}:v=1:a=1" -y $outputPath';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        print('Error merging videos: ${await session.getFailStackTrace()}');
        return null;
      }
    }
    return null;
  }
}
