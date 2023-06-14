import 'package:flutter/material.dart';

class SalesAnalysisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ModalRoute를 통해 전달받은 checkedList를 사용합니다.
    final checkedList = ModalRoute.of(context)!.settings.arguments as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('기간별 매출 분석'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '기간별 매출 추이',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            // TODO: 여기에서 checkedList를 사용하여 기간별 매출 데이터를 나타내는 위젯들을 추가하세요.
            Text('선택된 보고서 ID: $checkedList'),
          ],
        ),
      ),
    );
  }
}

