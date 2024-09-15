import 'dart:ui';
import 'save_emoji_as_image.dart'; // 이모티콘 이미지 변환 함수

Future<Map<String, String>> generateTextEmojiOverlayFilters(
    List<Map<String, dynamic>> elements,
    double videoWidth,
    double videoHeight
    ) async {
  List<String> filters = [];
  List<String> inputs = []; // 추가적인 입력 파일들을 위한 리스트
  int emojiIndex = 1; // 첫 번째 입력 파일은 비디오이므로, 이미지 입력은 두 번째부터
  String previousOutput = "[v0]"; // 첫 번째 필터의 출력은 컬러 매트릭스 필터로 처리된 비디오 스트림 [v0]
  bool isFirstOverlay = true; // 첫 번째 오버레이인지 확인하는 플래그

  for (int i = 0; i < elements.length; i++) {
    var element = elements[i];
    String content = element['content'];
    bool isEmoji = element['isEmoji'] ?? false;
    double size = element['size'] ?? 0.05;
    Offset position = element['position'] ?? const Offset(0, 0);

    // 크기 및 위치 계산
    double pixelSize = size * videoHeight;
    int xPosition = ((position.dx / videoWidth) * 1080).round(); // 좌표 보정
    int yPosition = ((position.dy / videoHeight) * 1920).round();

    // 이모티콘의 경우
    if (isEmoji) {
      String emojiPath = await saveEmojiAsImage(content, pixelSize, 3);

      // 이모티콘 이미지 파일을 입력으로 추가
      inputs.add('-i "$emojiPath"');

      if (isFirstOverlay) {
        // 첫 번째 오버레이에서는 컬러 매트릭스 필터를 적용한 스트림과 오버레이
        filters.add('[v0][${emojiIndex}:v]overlay=x=$xPosition:y=$yPosition[v1]');
        previousOutput = '[v1]';
        isFirstOverlay = false; // 첫 번째 오버레이 이후로는 더 이상 이 조건을 실행하지 않음
      } else {
        // 이후의 오버레이 처리
        filters.add('${previousOutput}[${emojiIndex}:v]overlay=x=$xPosition:y=$yPosition[v${emojiIndex + 1}]');
        previousOutput = "[v${emojiIndex + 1}]";
      }
      emojiIndex++; // 다음 입력 스트림 번호로 증가

    } else {
      // 텍스트의 경우 drawtext 필터 추가, 텍스트 특수문자 이스케이프
      filters.add('$previousOutput drawtext=text=\'${content.replaceAll("'", r"\'")}\':fontcolor=white:fontsize=${pixelSize}:x=$xPosition:y=$yPosition[v${emojiIndex + 1}]');

      // 다음 오버레이를 위해 현재 출력 스트림을 업데이트
      previousOutput = "[v${emojiIndex + 1}]";
      emojiIndex++;
    }
  }

  // 필터가 있을 때만 입력 파일과 필터 체인을 반환
  if (filters.isNotEmpty) {
    String inputFiles = inputs.join(' ');  // 입력 파일들
    String filterChain = filters.join(';');  // 필터 체인

    // 입력 파일들과 필터 체인을 각각 반환
    return {
      'inputs': inputFiles,
      'filters': filterChain
    };
  } else {
    return {'inputs': '', 'filters': ''}; // 필터가 없으면 빈 문자열 반환
  }
}






















