import 'dart:ui';
import 'save_emoji_as_image.dart'; // 이모티콘 이미지 변환 함수

Future<String> generateTextEmojiOverlayFilters(List<Map<String, dynamic>> elements) async {
  List<String> filters = [];

  // 1080x1920 해상도 기준
  const double videoHeight = 1920.0;
  const double videoWidth = 1080.0;

  for (var element in elements) {
    String content = element['content'];
    bool isEmoji = element['isEmoji'] ?? false;
    double size = element['size'] ?? 0.05; // 이모티콘 또는 텍스트의 크기 비율 (화면 높이 기준)
    Offset position = element['position'] ?? Offset(0, 0);

    // 이모티콘 또는 텍스트의 크기 계산
    double pixelSize = size * videoHeight;

    // 좌표 값 계산 (이모티콘 크기를 고려하여 비디오 영역을 넘지 않도록 제한)
    double xPosition = (position.dx * videoWidth).clamp(0, videoWidth - pixelSize);
    double yPosition = (position.dy * videoHeight).clamp(0, videoHeight - pixelSize);

    if (isEmoji) {
      // 이모티콘을 이미지 파일로 변환하여 overlay 필터 적용
      String emojiPath = await saveEmojiAsImage(content, pixelSize);

      // 대괄호 없이 파일 경로 전달
      filters.add('overlay=x=$xPosition:y=$yPosition:shortest=1:$emojiPath');
    } else {
      // 텍스트 추가(drawtext 필터 사용)
      filters.add(
          'drawtext=text=\'$content\':fontcolor=white:fontsize=${pixelSize}:x=$xPosition:y=$yPosition');
    }
  }

  return filters.join(', ');
}





