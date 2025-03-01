class SrtEntry {
  final int index;
  final String startTime;
  final String endTime;
  String text;

  SrtEntry({
    required this.index,
    required this.startTime,
    required this.endTime,
    required this.text,
  });
}