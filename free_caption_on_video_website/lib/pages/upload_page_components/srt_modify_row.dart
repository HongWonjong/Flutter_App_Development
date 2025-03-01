import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_caption_on_video_website/style/responsive_sizes.dart';
import 'dart:html' as html;

import '../../providers/ffmpeg_overlay_provider.dart';
import '../../providers/srt_provider.dart';
import '../../providers/subtle_style_provider.dart';
import '../../providers/video_provider.dart';
import '../../services/ffmpeg_overlay_service.dart';
import '../../services/indexdb_service.dart';
import 'custom_checkbox.dart';
import 'srt_modify_dialog.dart';
import 'subtle_editor_dialog.dart';

class SrtModifyRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final srtModifyState = ref.watch(srtModifyProvider);
    final videoState = ref.watch(videoProvider);
    final isChecked = srtModifyState.isModified;
    final isModified = srtModifyState.isModified;

    final indexedDbService = IndexedDbService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final buttons = [
              ElevatedButton(
                onPressed: () {
                  ref.read(srtModifyProvider.notifier).setEditing(true);
                  _showModifyDialog(context, ref);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveSizes.h3,
                    vertical: ResponsiveSizes.h2,
                  ),
                  textStyle: TextStyle(fontSize: ResponsiveSizes.textSize(3)),
                ),
                child: Text('SRT 편집'),
              ),
              if (isModified) ...[
                ElevatedButton(
                  onPressed: () {
                    final blob = html.Blob([srtModifyState.modifiedSrtContent!], 'text/srt');
                    final url = html.Url.createObjectUrlFromBlob(blob);
                    final anchor = html.AnchorElement(href: url)
                      ..setAttribute('download', 'modified_subtitles.srt')
                      ..click();
                    html.Url.revokeObjectUrl(url);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveSizes.h3,
                      vertical: ResponsiveSizes.h2,
                    ),
                    textStyle: TextStyle(fontSize: ResponsiveSizes.textSize(3)),
                  ),
                  child: Text('편집된 SRT 다운로드'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    debugPrint('동영상에 자막 오버레이 버튼 클릭');
                    if (videoState.videoKey == null || videoState.thumbnail == null || videoState.thumbnail!.isEmpty) {
                      debugPrint('비디오 또는 썸네일 없음: videoKey = ${videoState.videoKey}, thumbnail = ${videoState.thumbnail != null ? "있음 (${videoState.thumbnail!.length} bytes)" : "없음"}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('비디오 또는 썸네일이 없습니다.', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
                        ),
                      );
                      return;
                    }

                    debugPrint('썸네일 확인: ${videoState.thumbnail!.length} bytes');
                    final ffmpegService = ref.read(ffmpegOverlayServiceProvider);
                    final videoBytes = await indexedDbService.getVideo(videoState.videoKey!);
                    final srtContent = srtModifyState.modifiedSrtContent ?? srtModifyState.srtContent;
                    if (videoBytes != null && srtContent != null) {
                      final style = await showDialog<SubtitleStyleState>(
                        context: context,
                        builder: (_) => SubtitleEditorDialog(
                          frameImage: videoState.thumbnail!, // 썸네일 전달
                        ),
                      );
                      if (style != null) {
                        final result = await ffmpegService.overlaySrtOnVideo(
                          videoBytes,
                          srtContent,
                          {
                            'fontSize': style.fontSize,
                            'fontFamily': style.fontFamily,
                            'textColor': style.textColor,
                            'textOpacity': style.textOpacity,
                            'bgHeight': style.bgHeight,
                            'bgColor': style.bgColor,
                            'bgOpacity': style.bgOpacity,
                            'subtitlePosition': style.subtitlePosition,
                          },
                        );
                        if (result != null) {
                          debugPrint('자막 오버레이 성공: ${result.length} bytes');
                          final blob = html.Blob([result], 'video/mp4');
                          final url = html.Url.createObjectUrlFromBlob(blob);
                          final anchor = html.AnchorElement(href: url)
                            ..setAttribute('download', 'video_with_subtitles.mp4')
                            ..click();
                          html.Url.revokeObjectUrl(url);
                        } else {
                          debugPrint('자막 오버레이 실패');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('자막 삽입 실패', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
                            ),
                          );
                        }
                      }
                    } else {
                      debugPrint('비디오 또는 SRT 파일 없음');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('비디오 또는 SRT 파일이 없습니다.', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveSizes.h3,
                      vertical: ResponsiveSizes.h2,
                    ),
                    textStyle: TextStyle(fontSize: ResponsiveSizes.textSize(3)),
                  ),
                  child: Text('동영상에 자막 오버레이'),
                ),
              ],
            ];

            return isMobile
                ? Column(
              children: buttons
                  .map(
                    (btn) => Padding(
                  padding: EdgeInsets.only(left: ResponsiveSizes.h5),
                  child: btn,
                ),
              )
                  .toList(),
            )
                : Padding(
              padding: EdgeInsets.only(left: ResponsiveSizes.h5),
              child: Row(
                children: buttons
                    .map(
                      (btn) => Padding(
                    padding: EdgeInsets.only(right: ResponsiveSizes.h3),
                    child: btn,
                  ),
                )
                    .toList(),
              ),
            );
          },
        ),
        SizedBox(height: ResponsiveSizes.h2),
        Padding(
          padding: EdgeInsets.only(left: ResponsiveSizes.h5),
          child: CustomCheckbox(
            isChecked: isChecked,
            text: 'SRT 수정 완료',
          ),
        ),
      ],
    );
  }

  void _showModifyDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'SRT 편집',
            style: TextStyle(fontSize: ResponsiveSizes.textSize(3)),
          ),
          content: SrtModifyDialog(),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: TextStyle(fontSize: ResponsiveSizes.textSize(3)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                '제출',
                style: TextStyle(fontSize: ResponsiveSizes.textSize(3)),
              ),
            ),
          ],
        );
      },
    );
  }
}