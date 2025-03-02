import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../class/srt_entry.dart';
import '../../providers/srt_provider.dart';
import '../../style/editor_style.dart';

class SrtModifyDialog extends ConsumerStatefulWidget {
  const SrtModifyDialog({super.key});

  @override
  _SrtModifyDialogState createState() => _SrtModifyDialogState();
}

class _SrtModifyDialogState extends ConsumerState<SrtModifyDialog> {
  late List<SrtEntry> entries;

  @override
  void initState() {
    super.initState();
    final srtModifyState = ref.read(srtModifyProvider);
    entries = srtModifyState.modifiedSrtEntries.isNotEmpty
        ? List.from(srtModifyState.modifiedSrtEntries)
        : List.from(srtModifyState.parsedSrtEntries);
  }

  String _simplifyTimestamp(String timestamp) {
    final parts = timestamp.split(',')[0].split(':');
    final seconds = int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60 + int.parse(parts[2]);
    return '${seconds}초';
  }

  String _formatTimestampRange(String start, String end) {
    final startSeconds = _simplifyTimestamp(start).replaceAll('초', '');
    final endSeconds = _simplifyTimestamp(end).replaceAll('초', '');
    return '$startSeconds~$endSeconds초';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: AppStyles.dialogShape,
      elevation: AppStyles.dialogElevation,
      backgroundColor: AppStyles.dialogBackgroundColor,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            // 헤더
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: AppStyles.headerDecoration(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SRT 편집',
                    style: AppStyles.headerTextStyle(context),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppStyles.headerIconColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // 자막 리스트
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.all(12.0),
                        decoration: AppStyles.itemContainerDecoration,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 타임스탬프
                            Container(
                              width: 90,
                              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                              decoration: AppStyles.timestampBoxDecoration,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.index.toString(),
                                    style: AppStyles.timestampIndexTextStyle(context),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    _formatTimestampRange(entry.startTime, entry.endTime),
                                    style: AppStyles.timestampRangeTextStyle(context),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.0),
                            // 원본 텍스트
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(12.0),
                                decoration: AppStyles.textBoxDecoration,
                                child: Text(
                                  entry.originalText,
                                  style: AppStyles.textBoxTextStyle(context),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.0),
                            // 구분선
                            Container(
                              width: 2.0,
                              height: 40.0,
                              decoration: AppStyles.dividerDecoration,
                            ),
                            SizedBox(width: 12.0),
                            // 번역 텍스트
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(12.0),
                                decoration: AppStyles.textBoxDecoration,
                                child: Text(
                                  entry.text,
                                  style: AppStyles.textBoxTextStyle(context),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.0),
                            // 수정 텍스트
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: AppStyles.editTextFieldDecoration(context),
                                child: TextField(
                                  controller: TextEditingController(text: entry.text),
                                  decoration: AppStyles.editTextFieldInputDecoration,
                                  style: AppStyles.textBoxTextStyle(context),
                                  maxLines: null,
                                  onChanged: (value) {
                                    entry.text = value;
                                    ref.read(srtModifyProvider.notifier).updateModifiedEntries(entries);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // 하단 버튼
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: AppStyles.cancelButtonStyle,
                    child: Text('취소'),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(srtModifyProvider.notifier).setEditing(false);
                      Navigator.pop(context);
                    },
                    style: AppStyles.submitButtonStyle(context),
                    child: Text(
                      '제출',
                      style: AppStyles.submitButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}