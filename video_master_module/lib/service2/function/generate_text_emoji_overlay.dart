import 'dart:ui';
import 'save_emoji_as_image.dart'; // 이모티콘 이미지 변환 함수

Future<String> generateTextEmojiOverlayFilters(
    List<Map<String, dynamic>> elements,
    double videoWidth,
    double videoHeight
    ) async {
  List<String> filters = [];
  String lastOutput = "[in]"; // 시작은 원본 비디오

  for (int i = 0; i < elements.length; i++) {
    var element = elements[i];
    String content = element['content'];
    bool isEmoji = element['isEmoji'] ?? false;
    double size = element['size'] ?? 0.05;
    Offset position = element['position'] ?? const Offset(0, 0);

    double pixelSize = size * videoHeight;
    int xPosition = ((position.dx / videoWidth) * videoWidth).round(); // 레이아웃 빌더 좌측 상단의 오프셋은 늘 (0,0)이고, 우리는 너비와 높이를 안다. 보정이 가능하다.
    int yPosition = ((position.dy / videoHeight) * videoHeight).round();


    if (isEmoji) {
      String emojiPath = await saveEmojiAsImage(content, pixelSize);
      filters.add('$lastOutput overlay=x=$xPosition:y=$yPosition:shortest=1:$emojiPath [tmp$i]');
      lastOutput = '[tmp$i]';
    } else {
      filters.add('$lastOutput drawtext=text=\'$content\':fontcolor=white:fontsize=${pixelSize}:x=$xPosition:y=$yPosition [tmp$i]');
      lastOutput = '[tmp$i]';
    }
  }

  // 필터가 없을 때는 빈 필터를 반환하지 않음
  if (filters.isNotEmpty) {
    return filters.join('; ') + ' [out]';
  } else {
    return ''; // 필터가 없으면 빈 문자열 반환
  }
}













