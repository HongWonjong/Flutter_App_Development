import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';

class ImageProcessingService {
  // Image resizing and processing
  img.Image _resizeImageToFit(img.Image image, int maxWidth, int maxHeight) {
    final int originalWidth = image.width;
    final int originalHeight = image.height;

    double aspectRatio = originalWidth / originalHeight;

    int newWidth = maxWidth;
    int newHeight = (newWidth / aspectRatio).round();

    if (newHeight > maxHeight) {
      newHeight = maxHeight;
      newWidth = (newHeight * aspectRatio).round();
    }

    return img.copyResize(image, width: newWidth, height: newHeight);
  }

  // ABGR to RGBA conversion
  Uint8List _convertABGRtoRGBA(Uint8List abgrBytes) {
    Uint8List rgbaBytes = Uint8List(abgrBytes.length);
    for (int i = 0; i < abgrBytes.length; i += 4) {
      rgbaBytes[i] = abgrBytes[i + 2];     // B -> R
      rgbaBytes[i + 1] = abgrBytes[i + 1]; // G -> G
      rgbaBytes[i + 2] = abgrBytes[i];     // R -> B
      rgbaBytes[i + 3] = abgrBytes[i + 3]; // A -> A
    }
    return rgbaBytes;
  }

  Future<void> processImage(File imageFile) async {
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage != null) {
      img.Image resizedImage = _resizeImageToFit(decodedImage, 1920, 1080);
      img.Image background = img.Image(width: 1920, height: 1080);
      img.fill(background, color: img.ColorInt8.rgba(0, 0, 0, 255));

      int xOffset = (1920 - resizedImage.width) ~/ 2;
      int yOffset = (1080 - resizedImage.height) ~/ 2;
      img.Image finalImage = img.compositeImage(background, resizedImage, dstX: xOffset, dstY: yOffset);

      img.Image rgbaImage = finalImage.convert(numChannels: 4);
      Uint8List abgrBytes = Uint8List.fromList(rgbaImage.getBytes());
      Uint8List rgbaBytes = _convertABGRtoRGBA(abgrBytes);

      for (int i = 0; i < 90; i++) {
        await FlutterQuickVideoEncoder.appendVideoFrame(rgbaBytes);
      }
    }
  }
}
