import 'package:flutter/material.dart';

class SalesAnalysisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기간별 매출 분석'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text(
              '기간별 매출 추이',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            // TODO: 기간별 매출 데이터를 나타내는 위젯들을 추가하세요.
          ],
        ),
      ),
    );
  }
}
