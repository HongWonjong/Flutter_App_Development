import 'dart:ui';
import 'save_emoji_as_image.dart'; // 이모티콘 이미지 변환 함수
import 'dart:math';

Future<Map<String, String>> generateTextEmojiOverlayFilters(
    List<Map<String, dynamic>> elements,
    double videoWidth,
    double videoHeight
    ) async {
  List<String> filters = [];
  List<String> inputs = []; // 추가적인 입력 파일들을 위한 리스트
  int emojiIndex = 1; // 첫 번째 입력 파일은 비디오이므로, 이미지 입력은 두 번째부터
  String previousOutput = "[v0]"; // 첫 번째 필터의 출력은 컬러 매트릭스 필터로 처리된 비디오 스트림 [v0]

  for (int i = 0; i < elements.length; i++) {
    var element = elements[i];
    String content = element['content'];
    double size = element['size'] ?? 0.05;
    Offset position = element['position'] ?? const Offset(0, 0);

    // 크기 및 위치 계산
    double pixelSize = size * videoHeight;
    int xPosition = ((position.dx / videoWidth) * 1080).round(); // 좌표 보정
    int yPosition = ((position.dy / videoHeight) * 1920).round();

    // 영상 크기 기반으로 크기 조정
    double scaleFactor = sqrt((1080 * 1920) / (videoWidth * videoHeight));

      String emojiPath = await saveEmojiAsImage(content, pixelSize, scaleFactor);

      // 이모티콘 이미지 파일을 입력으로 추가
      inputs.add('-i "$emojiPath"');

      if (i == 0) {
        // 첫 번째 오버레이 처리
        filters.add('[v0][1:v]overlay=x=$xPosition:y=$yPosition[v1]');
        previousOutput = '[v1]';  // 첫 오버레이가 끝난 후에 previousOutput 업데이트
      } else {
        // 그 이후의 오버레이는 previousOutput을 참조하여 연결
        filters.add('$previousOutput[$emojiIndex:v]overlay=x=$xPosition:y=$yPosition[v$emojiIndex]');
        previousOutput = "[v$emojiIndex]";  // 새로운 출력 스트림을 참조하도록 업데이트
      }
      emojiIndex++; // 다음 입력 스트림 번호로 증가
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























