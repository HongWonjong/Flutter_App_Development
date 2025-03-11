// 표 위젯의 전체 공간 차지하도록 수정
import 'package:flutter/material.dart';

class TableElementWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(), // 테두리 추가
      children: [
        TableRow(
          children: [
            Container(
              padding: const EdgeInsets.all(8), // 패딩 설정
              child: Text('셀 1'),
            ),
            Container(
              padding: const EdgeInsets.all(8), // 패딩 설정
              child: Text('셀 2'),
            ),
          ],
        ),
        // 추가적인 TableRow 추가
      ],
    );
  }
}
