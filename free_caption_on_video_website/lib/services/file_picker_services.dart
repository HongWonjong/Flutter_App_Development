import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class FilePickerService {
  Future<Uint8List?> pickVideoFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video, // 비디오 파일만 선택 가능
        allowMultiple: false, // 단일 파일만 허용
        withData: true, // 파일 데이터를 메모리에 로드
      );

      if (result != null && result.files.isNotEmpty) {
        // 선택된 파일의 바이트 데이터를 반환
        return result.files.first.bytes;
      }
      return null; // 파일 선택 안 했을 경우
    } catch (e) {
      print('비디오 파일 선택 중 오류: $e');
      return null;
    }
  }
}