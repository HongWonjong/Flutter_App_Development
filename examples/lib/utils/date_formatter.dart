import 'package:intl/intl.dart';

class DateFormatter {
  // 날짜를 '2023년 12월 31일' 형식으로 변환
  static String formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  // 날짜를 '2023/12/31' 형식으로 변환
  static String formatShortDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  // 날짜를 '오늘', '어제', '그제', 또는 날짜 형식으로 변환
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    final compareDate = DateTime(date.year, date.month, date.day);

    if (compareDate == today) {
      return '오늘';
    } else if (compareDate == yesterday) {
      return '어제';
    } else if (compareDate == twoDaysAgo) {
      return '그제';
    } else {
      return formatShortDate(date);
    }
  }

  static String format(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('yyyy.MM.dd').format(date);
    }
  }
}
