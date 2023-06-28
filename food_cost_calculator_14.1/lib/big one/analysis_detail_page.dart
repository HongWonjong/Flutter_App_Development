import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_cost_calculator_3_0/small one/custom_appbar.dart';

class AnalysisDetailPage extends StatelessWidget {
  final replyData;

  const AnalysisDetailPage({Key? key, required this.replyData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String response = '';
    DateTime createdAt;

    try {
      createdAt = (replyData['status']['created_at'] as Timestamp).toDate();
      response = replyData['response'] ?? 'No response';
    } catch (e) {
      // If an error occurs, the fields are populated with an error message
      createdAt = DateTime.now();
      response = '이 문구가 뜬다면 아직 GPT가 요청에 응답 중입니다...보통 20초 이내에 응답이 완료됩니다.';
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
            Text(response),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}

