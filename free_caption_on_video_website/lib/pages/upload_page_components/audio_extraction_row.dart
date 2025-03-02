import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/custom_checkbox.dart';
import 'package:free_caption_on_video_website/style/responsive_sizes.dart';
import 'package:free_caption_on_video_website/services/transcribe_count_service.dart';

import 'custom_buttons.dart';


class AudioExtractionRow extends StatelessWidget {
  final bool isChecked;
  final String text;
  final String? errorMessage;
  final bool hasErrorDisplayed;
  final int? audioFileSize;
  final Uint8List? audioData;
  final String Function(int?) formatFileSize;
  final VoidCallback onDownloadPressed;
  final VoidCallback onTranscribePressed;
  final String? srtContent;
  final VoidCallback onSrtDownloadPressed;

   AudioExtractionRow({
    super.key,
    required this.isChecked,
    required this.text,
    this.errorMessage,
    this.hasErrorDisplayed = false,
    this.audioFileSize,
    this.audioData,
    required this.formatFileSize,
    required this.onDownloadPressed,
    required this.onTranscribePressed,
    this.srtContent,
    required this.onSrtDownloadPressed,
  });

  final _transcribeCountService = TranscribeCountService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCheckbox(
          isChecked: isChecked,
          text: text,
        ),
        if (!isChecked && errorMessage != null && hasErrorDisplayed)
          Padding(
            padding: EdgeInsets.only(left: ResponsiveSizes.h5),
            child: SelectableText(
              '오류: $errorMessage',
              style: TextStyle(
                color: Colors.red,
                fontSize: ResponsiveSizes.textSize(2),
              ),
            ),
          ),
        if (isChecked && audioFileSize != null)
          Padding(
            padding: EdgeInsets.only(left: ResponsiveSizes.h5),
            child: Text(
              '용량: ${formatFileSize(audioFileSize)}',
              style: TextStyle(fontSize: ResponsiveSizes.textSize(2)),
            ),
          ),
        SizedBox(height: ResponsiveSizes.h2),
        if (isChecked && audioData != null)
          Padding(
            padding: EdgeInsets.only(left: ResponsiveSizes.h5),
            child: Row(
              children: [
                CustomButton( // ElevatedButton → CustomButton
                  text: 'mp3 다운로드',
                  onPressed: onDownloadPressed,
                ),
                SizedBox(width: ResponsiveSizes.h3),
                CustomButton( // ElevatedButton → CustomButton
                  text: 'mp3 -> SRT 변환',
                  onPressed: () async {
                    await _transcribeCountService.incrementTranscribeCount(); // Firestore에 카운트 증가
                    onTranscribePressed(); // 기존 동작 호출
                  },
                ),
                if (srtContent != null) ...[
                  SizedBox(width: ResponsiveSizes.h3),
                  CustomButton( // ElevatedButton → CustomButton
                    text: '원본 SRT 다운로드',
                    onPressed: onSrtDownloadPressed,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}