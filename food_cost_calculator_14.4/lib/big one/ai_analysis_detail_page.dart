import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_cost_calculator_3_0/small one/custom_appbar.dart';

class AnalysisDetailPage extends StatefulWidget {
  final replyData;

  const AnalysisDetailPage({Key? key, required this.replyData}) : super(key: key);

  @override
  _AnalysisDetailPageState createState() => _AnalysisDetailPageState();
}

class _AnalysisDetailPageState extends State<AnalysisDetailPage> {
  bool _isLargeText = false;

  @override
  Widget build(BuildContext context) {
    String response = '';
    DateTime createdAt;

    try {
      createdAt = (widget.replyData['status']['created_at'] as Timestamp).toDate();
      response = widget.replyData['response'] ?? 'No response';
    } catch (e) {
      // If an error occurs, the fields are populated with an error message
      createdAt = DateTime.now();
      response = '아직 GPT가 요청에 응답 중입니다...잠시 후 다시 들어와주세요.';
    }

    return Scaffold(
      appBar: const MyAppBar(title: 'AI 분석 세부사항'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Text('응답 시간: $createdAt', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16.0),
            Text('응답 내용:', style: Theme.of(context).textTheme.titleLarge),
            SwitchListTile(
              title: const Text('큰 글자'),
              value: _isLargeText,
              onChanged: (bool value) {
                setState(() {
                  _isLargeText = value;
                });
              },
            ),
            const SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurpleAccent),
                color: Colors.white,
              ),
              child: Text(
                response,
                style: TextStyle(fontSize: _isLargeText ? 20.0 : 16.0), // 기본 글씨 크기는 16.0, 큰 글씨는 20.0으로 설정
              ),
            ),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}




