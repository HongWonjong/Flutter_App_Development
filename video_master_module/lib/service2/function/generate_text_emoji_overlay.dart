import 'dart:ui';
import 'save_emoji_as_image.dart'; // 이모티콘 이미지 변환 함수

Future<String> generateTextEmojiOverlayFilters(
    List<Map<String, dynamic>> elements,
    Offset videoEditorTopLeft,
    double videoWidth,
    double videoHeight
    ) async {
  List<String> filters = [];

  for (var element in elements) {
    String content = element['content'];
    bool isEmoji = element['isEmoji'] ?? false;
    double size = element['size'] ?? 0.05;
    Offset position = element['position'] ?? const Offset(0, 0);

    // 이모티콘 또는 텍스트의 크기 계산
    double pixelSize = size * videoHeight;

    // 위치를 계산하고 근사치를 정수로 변환
    int xPosition = ((position.dx / videoWidth) * videoWidth).round(); //
    int yPosition = ((position.dy / videoHeight) * videoHeight).round(); // y 좌표 반올림

    if (isEmoji) {
      String emojiPath = await saveEmojiAsImage(content, pixelSize);
      filters.add('overlay=x=$xPosition:y=$yPosition:shortest=1:$emojiPath');
    } else {
      filters.add('drawtext=text=\'$content\':fontcolor=white:fontsize=${pixelSize}:x=$xPosition:y=$yPosition');
    }
  }

  return filters.join(', ');
}










