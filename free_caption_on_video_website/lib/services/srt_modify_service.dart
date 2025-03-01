import '../class/srt_entry.dart';

class SrtModifyService {
  static List<SrtEntry> parseSrt(String srtContent) {
    final entries = <SrtEntry>[];
    final lines = srtContent.split('\n');
    int index = 0;
    String startTime = '';
    String endTime = '';
    String text = '';

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (int.tryParse(line) != null) {
        if (index != 0) {
          entries.add(SrtEntry(
            index: index,
            startTime: startTime,
            endTime: endTime,
            text: text.trim(),
          ));
        }
        index = int.parse(line);
        text = '';
      } else if (line.contains('-->')) {
        final times = line.split('-->');
        startTime = times[0].trim();
        endTime = times[1].trim();
      } else {
        text += line + '\n';
      }
    }

    if (index != 0) {
      entries.add(SrtEntry(
        index: index,
        startTime: startTime,
        endTime: endTime,
        text: text.trim(),
      ));
    }

    return entries;
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