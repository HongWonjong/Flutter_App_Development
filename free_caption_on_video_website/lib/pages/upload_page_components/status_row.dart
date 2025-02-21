import 'package:flutter/material.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/custom_checkbox.dart';
import 'package:free_caption_on_video_website/style/responsive_sizes.dart';

class StatusRow extends StatelessWidget {
  final bool isChecked;
  final String text;
  final String? errorMessage;
  final bool hasErrorDisplayed;

  const StatusRow({
    super.key,
    required this.isChecked,
    required this.text,
    this.errorMessage,
    this.hasErrorDisplayed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
      children: [
        // 체크박스와 텍스트
        CustomCheckbox(
          isChecked: isChecked,
          text: text,
        ),
        // 오류 메시지 (오류가 있을 때)
        if (errorMessage != null && hasErrorDisplayed)
          Padding(
            padding: EdgeInsets.only(left: ResponsiveSizes.h5, top: ResponsiveSizes.h2), // 들여쓰기 및 위쪽 간격
            child: SelectableText(
              '오류: $errorMessage',
              style: TextStyle(
                color: Colors.red,
                fontSize: ResponsiveSizes.textSize(2),
              ),
            ),
          ),
      ],
    );
  }
}