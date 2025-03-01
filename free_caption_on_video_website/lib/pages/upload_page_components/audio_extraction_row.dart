import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/custom_checkbox.dart';
import 'package:free_caption_on_video_website/style/responsive_sizes.dart'; // 추가
import 'dart:html' as html;

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

  const AudioExtractionRow({
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
        // 오류 메시지 (체크 안 된 상태에서 오류가 있을 때)
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
        // 오디오 용량 정보 (체크된 상태에서 용량이 있을 때)
        if (isChecked && audioFileSize != null)
          Padding(
            padding: EdgeInsets.only(left: ResponsiveSizes.h5),
            child: Text(
              '용량: ${formatFileSize(audioFileSize)}',
              style: TextStyle(fontSize: ResponsiveSizes.textSize(2)),
            ),
          ),
        SizedBox(height: ResponsiveSizes.h2),

        // 버튼들 (오디오 데이터가 있을 때)
        if (isChecked && audioData != null)
          Padding(
            padding: EdgeInsets.only(left: ResponsiveSizes.h5),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: onDownloadPressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveSizes.h3,
                      vertical: ResponsiveSizes.h2,
                    ),
                    textStyle: TextStyle(fontSize: ResponsiveSizes.textSize(3)),
                  ),
                  child: const Text('다운로드'),
                ),
                SizedBox(width: ResponsiveSizes.h3),
                ElevatedButton(
                  onPressed: onTranscribePressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveSizes.h3,
                      vertical: ResponsiveSizes.h2,
                    ),
                    textStyle: TextStyle(fontSize: ResponsiveSizes.textSize(3)),
                  ),
                  child: const Text('SRT로 변환'),
                ),

                if (srtContent != null) ...[
                  SizedBox(width: ResponsiveSizes.h3),
                  ElevatedButton(
                    onPressed: onSrtDownloadPressed,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveSizes.h3,
                        vertical: ResponsiveSizes.h2,
                      ),
                      textStyle:
                      TextStyle(fontSize: ResponsiveSizes.textSize(3)),
                    ),
                    child: const Text('원본 SRT 다운로드'),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}