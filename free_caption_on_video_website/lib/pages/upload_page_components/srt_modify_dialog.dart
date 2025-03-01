import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../class/srt_entry.dart';
import '../../providers/srt_provider.dart';

class SrtModifyDialog extends ConsumerStatefulWidget {
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

  // 타임스탬프를 초 단위로 간소화하는 함수
  String _formatTimestamp(String timestamp) {
    final parts = timestamp.split(',');
    if (parts.length == 2) {
      return parts[0]; // 초 단위까지만 반환 (예: 00:00:00)
    }
    return timestamp;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8, // 다이얼로그 너비를 화면의 80%로 설정
      height: MediaQuery.of(context).size.height * 0.7, // 다이얼로그 높이를 화면의 70%로 제한
      child: SingleChildScrollView(
        child: Column(
          children: entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0), // 줄 간 여백 증가
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white, // 흰색 배경
                  borderRadius: BorderRadius.circular(8.0), // 둥근 모서리
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // 그림자 효과
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 타임스탬프 영역
                    Container(
                      width: 150, // 고정 너비 설정
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black), // 검은색 테두리
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.index.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_formatTimestamp(entry.startTime)} --> ${_formatTimestamp(entry.endTime)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10), // 구분을 위한 여백

                    // 원본 텍스트 영역
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black), // 검은색 테두리
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          entry.text,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // 구분을 위한 여백

                    // 수정할 텍스트 영역
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black), // 검은색 테두리
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: TextField(
                          controller: TextEditingController(text: entry.text),
                          decoration: InputDecoration(
                            border: InputBorder.none, // 내부 테두리 제거
                            contentPadding: EdgeInsets.zero, // 여백 제거
                          ),
                          maxLines: null, // 여러 줄 입력 가능
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
    );
  }
}