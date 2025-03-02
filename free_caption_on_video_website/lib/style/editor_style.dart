import 'package:flutter/material.dart';
import 'package:free_caption_on_video_website/style/responsive_sizes.dart'; // 반응형 크기 사용을 위해 임포트

class AppStyles {
  // 다이얼로그 스타일
  static const dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  );
  static const dialogElevation = 8.0;
  static final dialogBackgroundColor = Colors.grey[100];

  // 헤더 스타일
  static BoxDecoration headerDecoration(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: theme.primaryColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
    );
  }
  static TextStyle headerTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleLarge!.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: ResponsiveSizes.textSize(3),
    );
  }
  static const headerIconColor = Colors.white;

  // 항목 컨테이너 스타일
  static BoxDecoration itemContainerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 2,
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ],
  );

  // 타임스탬프 박스 스타일
  static BoxDecoration timestampBoxDecoration = BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(color: Colors.grey[400]!),
  );
  static TextStyle timestampIndexTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium!.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.primaryColor,
    );
  }
  static TextStyle timestampRangeTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall!.copyWith(
      color: Colors.grey[600],
    );
  }

  // 텍스트 박스 스타일 (원본/번역)
  static BoxDecoration textBoxDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(color: Colors.grey[300]!),
  );
  static TextStyle textBoxTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium!.copyWith(
      color: Colors.black87,
    );
  }

  // 구분선 스타일
  static BoxDecoration dividerDecoration = BoxDecoration(
    color: Colors.grey[300],
  );

  // 수정 텍스트 필드 스타일
  static BoxDecoration editTextFieldDecoration(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
    );
  }
  static InputDecoration editTextFieldInputDecoration = InputDecoration(
    border: InputBorder.none,
    hintText: '여기를 수정하세요',
    hintStyle: TextStyle(color: Colors.grey[400]),
    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
  );

  // 버튼 스타일
  static ButtonStyle cancelButtonStyle = TextButton.styleFrom(
    foregroundColor: Colors.grey[600],
    textStyle: TextStyle(fontSize: ResponsiveSizes.textSize(3)),
  );
  static ButtonStyle submitButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.styleFrom(
      backgroundColor: theme.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    );
  }
  static TextStyle submitButtonTextStyle = TextStyle(
    fontSize: ResponsiveSizes.textSize(3),
    color: Colors.white,
  );
}