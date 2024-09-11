import 'dart:io';
import 'dart:typed_data'; // Uint8List 사용을 위한 import 추가
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:image/image.dart' as img; // 이미지 데이터 처리를 위한 패키지

class MediaService {
  final ImagePicker _picker = ImagePicker();

  // ABGR을 RGBA로 변환하는 함수 (상단으로 이동)
  Uint8List _convertABGRtoRGBA(Uint8List abgrBytes) {
    Uint8List rgbaBytes = Uint8List(abgrBytes.length);

    for (int i = 0; i < abgrBytes.length; i += 4) {
      rgbaBytes[i] = abgrBytes[i + 3];     // R
      rgbaBytes[i + 1] = abgrBytes[i + 2]; // G
      rgbaBytes[i + 2] = abgrBytes[i + 1]; // B
      rgbaBytes[i + 3] = abgrBytes[i];     // A
    }

    return rgbaBytes;
  }

  // 미디어 선택 (이미지 선택) 함수
  Future<List<File>> pickMedia() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      // XFile을 File로 변환하여 반환
      return pickedFiles.map((xfile) => File(xfile.path)).toList();
    }
    return [];
  }

  // 이미지 데이터를 RGBA로 변환하여 비디오로 만들기
  Future<String?> mergeMedia(List<File> mediaFiles) async {
    if (mediaFiles.isEmpty) {
      print("No media files to merge");
      return null;
    }

    // 비디오 설정 (1280x720 해상도)
    final tempDir = await getTemporaryDirectory();
    final videoPath = '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';

    await FlutterQuickVideoEncoder.setup(
      width: 1280,
      height: 720, // 세팅 높이를 540으로 설정하고, 이미지의 규격은 720으로 조정하면, 이거 개발자가 멍청하게 코드를 짜놔서 그런 걸지도 모르지만 놀랍게도 규격이 맞는다.
      fps: 30,
      videoBitrate: 2500000,
      audioChannels: 2,
      audioBitrate: 128000,
      sampleRate: 44100,
      profileLevel: ProfileLevel.highAutoLevel,
      filepath: videoPath,
    );

    // 각 이미지 데이터를 RGBA로 변환하여 비디오로 추가
    for (File imageFile in mediaFiles) {
      await _processImage(imageFile);
    }

    // 비디오 저장 완료
    await FlutterQuickVideoEncoder.finish();
    print("Video created at: $videoPath");
    return videoPath;
  }

  // 이미지를 RGBA 형식으로 처리
  Future<void> _processImage(File imageFile) async {
    // 이미지 파일을 로드하여 ABGR 바이트 데이터로 변환
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage != null) {
      // 이미지를 1280x720 해상도로 강제 리사이즈
      final img.Image resizedImage = img.copyResize(decodedImage, width: 1280, height: 960, interpolation: img.Interpolation.nearest);

      // 리사이즈된 이미지의 ABGR 바이트 데이터 추출
      Uint8List abgrBytes = Uint8List.fromList(resizedImage.getBytes());

      // ABGR을 RGBA로 변환
      Uint8List rgbaBytes = _convertABGRtoRGBA(abgrBytes);

      // RGBA 데이터 길이가 올바른지 확인
      if (rgbaBytes.length != 1280 * 720 * 4) {
        print('Error: RGBA data length is invalid. Expected: ${1280 * 720 * 4}, Actual: ${rgbaBytes.length}');
        return;
      }

      // 1초를 구성하는 30프레임 추가 (30fps 기준)
      for (int i = 0; i < 30; i++) {
        await FlutterQuickVideoEncoder.appendVideoFrame(rgbaBytes);
      }
    } else {
      print("Error decoding image: ${imageFile.path}");
    }
  }
}











