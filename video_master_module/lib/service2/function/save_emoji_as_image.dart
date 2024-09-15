import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// 이모티콘을 이미지 파일로 변환하여 파일 경로 반환
Future<String> saveEmojiAsImage(String emoji, double size, double scaleFactor) async {
  final recorder = ui.PictureRecorder();

  // 텍스트 크기 설정
  final textPainter = TextPainter(
    text: TextSpan(
      text: emoji,
      style: TextStyle(
        fontSize: size * scaleFactor, // 이모티콘 크기를 scaleFactor로 조정
        fontFamily: 'NotoColorEmoji', // 이모티콘을 지원하는 폰트
      ),
    ),
    textDirection: TextDirection.ltr,
  );

  // 텍스트 레이아웃 계산
  textPainter.layout();

  // 텍스트의 실제 크기를 기반으로 캔버스 크기 설정 (텍스트 크기만큼만 캔버스 생성)
  final paletteWidth = textPainter.width;
  final paletteHeight = textPainter.height;

  // 정확한 텍스트 크기로 캔버스 생성
  final canvas = Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(paletteWidth, paletteHeight)));

  // 이모티콘을 캔버스에 그리기
  textPainter.paint(canvas, Offset(0, 0));

  // 이미지로 변환
  final picture = recorder.endRecording();
  final img = await picture.toImage(paletteWidth.toInt(), paletteHeight.toInt());  // 텍스트 크기에 맞춰 이미지 생성

  try {
    // 이미지 데이터를 PNG로 변환
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw Exception("Failed to convert image to byte data");

    final buffer = byteData.buffer.asUint8List();

    // 파일 저장 경로 설정
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_emoji.png';

    // 파일로 저장
    final file = await File(filePath).writeAsBytes(buffer);
    print("Emoji image saved at: $filePath");

    return file.path; // 이미지 파일 경로 반환
  } catch (e) {
    print('Error saving emoji as image: $e');
    return ''; // 에러 발생 시 빈 문자열 반환
  }
}


