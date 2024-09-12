import 'dart:io';
import 'dart:typed_data'; // Uint8List 사용을 위한 import 추가
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:image/image.dart' as img; // 이미지 데이터 처리를 위한 패키지

class MediaService {
  final ImagePicker _picker = ImagePicker();

  // ABGR을 RGBA로 변환하는 함수
  Uint8List _convertABGRtoRGBA(Uint8List abgrBytes) {
    Uint8List rgbaBytes = Uint8List(abgrBytes.length);
    for (int i = 0; i < abgrBytes.length; i += 4) {
      rgbaBytes[i] = abgrBytes[i + 2];     // B -> R
      rgbaBytes[i + 1] = abgrBytes[i + 1]; // G -> G
      rgbaBytes[i + 2] = abgrBytes[i];     // R -> B
      rgbaBytes[i + 3] = abgrBytes[i + 3]; // A -> A (그대로 유지)
    }
    return rgbaBytes;
  }


  // 미디어 선택 (이미지 선택) 함수
  Future<List<File>> pickMedia() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
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

    final tempDir = await getTemporaryDirectory();
    final videoPath = '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';

    await FlutterQuickVideoEncoder.setup(
      width: 1920,
      height: 1080, // 해상도를 1080으로 설정
      fps: 30,
      videoBitrate: 5000000,
      audioChannels: 2,
      audioBitrate: 128000,
      sampleRate: 44100,
      profileLevel: ProfileLevel.highAutoLevel,
      filepath: videoPath,
    );

    for (File imageFile in mediaFiles) {
      await _processImage(imageFile);
    }

    await FlutterQuickVideoEncoder.finish();
    print("Video created at: $videoPath");
    return videoPath;
  }

  // 이미지를 RGBA 형식으로 처리
  Future<void> _processImage(File imageFile) async {
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage != null) {
      print('Image loaded successfully. Original size: ${decodedImage.width}x${decodedImage.height}');

      // 비율을 유지하여 이미지 리사이즈
      img.Image resizedImage = _resizeImageToFit(decodedImage, 1920, 1080);
      print('Image resized to: ${resizedImage.width}x${resizedImage.height}');

      // 1920x1080 크기의 검은색 배경 이미지 생성
      img.Image background = img.Image(width: 1920, height: 1080);
      img.fill(background, color: img.ColorInt8.rgba(0,0,0,255));

      // 리사이즈된 이미지를 중앙에 배치 using compositeImage
      int xOffset = (1920 - resizedImage.width) ~/ 2;
      int yOffset = (1080 - resizedImage.height) ~/ 2;
      img.Image finalImage = img.compositeImage(background, resizedImage, dstX: xOffset, dstY: yOffset);
      print('Image composited onto background. Final image size: ${finalImage.width}x${finalImage.height}');

      // RGBA 형식으로 변환
      img.Image rgbaImage = convertToRGBA(finalImage); // RGBA로 변환
      Uint8List abgrBytes = Uint8List.fromList(rgbaImage.getBytes());
      print('ABGR byte data length: ${abgrBytes.length}');

      Uint8List rgbaBytes = _convertABGRtoRGBA(abgrBytes);  // ABGR to RGBA 변환
      print('RGBA byte data length: ${rgbaBytes.length}');

      if (rgbaBytes.length != 1920 * 1080 * 4) {
        print('Error: RGBA data length is invalid. Expected: ${1920 * 1080 * 4}, Actual: ${rgbaBytes.length}');
        return;
      }

      // 3초 동안 이미지를 보여주기 위해 90프레임(30fps * 3초) 추가
      for (int i = 0; i < 90; i++) {
        await FlutterQuickVideoEncoder.appendVideoFrame(rgbaBytes);
      }
    } else {
      print("Error decoding image: ${imageFile.path}");
    }
  }

  // 이미지를 RGBA로 변환하는 함수
  img.Image convertToRGBA(img.Image image) {
    final rgba = image.convert(numChannels: 4);  // 4채널(RGBA)로 변환
    return rgba;
  }

  // 비율을 유지하며 이미지 리사이즈하는 함수
  img.Image _resizeImageToFit(img.Image image, int maxWidth, int maxHeight) {
    final int originalWidth = image.width;
    final int originalHeight = image.height;

    // 비율 계산
    double aspectRatio = originalWidth / originalHeight;

    int newWidth = maxWidth;
    int newHeight = (newWidth / aspectRatio).round();

    if (newHeight > maxHeight) {
      newHeight = maxHeight;
      newWidth = (newHeight * aspectRatio).round();
    }

    return img.copyResize(image, width: newWidth, height: newHeight);
  }
}





