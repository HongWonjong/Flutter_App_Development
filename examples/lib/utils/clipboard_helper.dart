import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/memo_element.dart';

class ClipboardHelper {
  // 클립보드에서 이미지 가져오기
  static Future<File?> getImageFromClipboard(BuildContext context) async {
    try {
      // 클립보드에서 이미지 데이터 가져오기
      final imageBytes = await Pasteboard.image;

      if (imageBytes != null) {
        // 임시 파일로 저장
        final tempDir = await getTemporaryDirectory();
        final fileName =
            'clipboard_image_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(imageBytes);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('클립보드에서 이미지를 가져왔습니다')));

        return file;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지 붙여넣기 실패: $e')));
    }
    return null;
  }

  // 이미지 파일로부터 메모 요소 생성
  static ImageElement createImageElement(File imageFile, double screenHeight) {
    const uuid = Uuid();

    return ImageElement(
      id: uuid.v4(),
      path: imageFile.path,
      width: 200.0, // 기본 너비
      height: 200.0, // 기본 높이
      xFactor: 0.1, // 화면 왼쪽에서 10% 위치
      yFactor: 0.3, // 화면 상단에서 30% 위치 (적절히 조정 필요)
    );
  }
}
