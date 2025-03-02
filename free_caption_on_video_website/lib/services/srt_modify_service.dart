import '../class/srt_entry.dart';

class SrtModifyService {
  static List<SrtEntry> parseSrt(String translatedSrt, String originalSrt) {
    final translatedEntries = <SrtEntry>[];
    final translatedLines = translatedSrt.split('\n');
    final originalLines = originalSrt.split('\n');
    int translatedIndex = 0;
    String startTime = '';
    String endTime = '';
    String translatedText = '';
    String originalText = '';

    // 번역 SRT 파싱
    int lineIndex = 0;
    while (lineIndex < translatedLines.length) {
      var line = translatedLines[lineIndex].trim();
      if (line.isEmpty) {
        lineIndex++;
        continue;
      }

      if (int.tryParse(line) != null) {
        if (translatedIndex != 0) {
          translatedEntries.add(SrtEntry(
            index: translatedIndex,
            startTime: startTime,
            endTime: endTime,
            text: translatedText.trim(),
            originalText: _getOriginalText(originalLines, translatedIndex),
          ));
        }
        translatedIndex = int.parse(line);
        translatedText = '';
      } else if (line.contains('-->')) {
        final times = line.split('-->');
        startTime = times[0].trim();
        endTime = times[1].trim();
      } else {
        translatedText += line + '\n';
      }
      lineIndex++;
    }

    if (translatedIndex != 0) {
      translatedEntries.add(SrtEntry(
        index: translatedIndex,
        startTime: startTime,
        endTime: endTime,
        text: translatedText.trim(),
        originalText: _getOriginalText(originalLines, translatedIndex),
      ));
    }

    return translatedEntries;
  }

  // 원본 SRT에서 해당 인덱스의 텍스트 추출
  static String _getOriginalText(List<String> originalLines, int targetIndex) {
    int currentIndex = 0;
    String originalText = '';

    int lineIndex = 0;
    while (lineIndex < originalLines.length) {
      var line = originalLines[lineIndex].trim();
      if (line.isEmpty) {
        lineIndex++;
        continue;
      }

      if (int.tryParse(line) != null) {
        currentIndex = int.parse(line);
        if (currentIndex == targetIndex) {
          // 인덱스 찾음, 다음 줄은 타임스탬프, 그 다음부터 텍스트
          lineIndex += 2; // 타임스탬프 건너뛰기
          while (lineIndex < originalLines.length && originalLines[lineIndex].trim().isNotEmpty) {
            originalText += originalLines[lineIndex].trim() + '\n';
            lineIndex++;
          }
          return originalText.trim();
        }
      }
      lineIndex++;
    }
    return ''; // 매칭되는 인덱스 없으면 빈 문자열 반환
  }

  static String updateSrt(List<SrtEntry> entries) {
    final buffer = StringBuffer();
    for (var entry in entries) {
      buffer.writeln(entry.index);
      buffer.writeln('${entry.startTime} --> ${entry.endTime}');
      buffer.writeln(entry.text);
      buffer.writeln();
    }
    return buffer.toString();
  }
}