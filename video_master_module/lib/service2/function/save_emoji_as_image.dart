import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// 이모티콘을 이미지 파일로 변환하여 파일 경로 반환
Future<String> saveEmojiAsImage(String emoji, double size) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(size, size)));

  // 이모티콘을 텍스트로 그림
  final textPainter = TextPainter(
    text: TextSpan(
      text: emoji,
      style: TextStyle(fontSize: size),
    ),
    textDirection: TextDirection.ltr,
  );

  textPainter.layout(minWidth: 0, maxWidth: size);
  textPainter.paint(canvas, const Offset(0, 0));

  // 이미지로 변환
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());

  // 이미지 데이터를 PNG로 변환
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  // 파일 저장 경로
  final tempDir = await getTemporaryDirectory();
  final filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_emoji.png';

  // 파일 저장
  final file = await File(filePath).writeAsBytes(buffer);

  return file.path; // 이미지 파일 경로 반환
}
