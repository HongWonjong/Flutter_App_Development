class SrtEntry {
  final int index;
  final String startTime;
  final String endTime;
  String text;         // 번역된 텍스트 (수정 가능)
  final String originalText; // 원본 텍스트 (수정 불가)

  SrtEntry({
    required this.index,
    required this.startTime,
    required this.endTime,
    required this.text,
    required this.originalText,
  });

  // SRT 문자열에서 객체 생성
  factory SrtEntry.fromSrt(String srtBlock, String originalBlock) {
    final lines = srtBlock.trim().split('\n');
    final originalLines = originalBlock.trim().split('\n');
    final index = int.parse(lines[0]);
    final times = lines[1].split(' --> ');
    return SrtEntry(
      index: index,
      startTime: times[0],
      endTime: times[1],
      text: lines.sublist(2).join('\n').trim(),
      originalText: originalLines.sublist(2).join('\n').trim(),
    );
  }
}