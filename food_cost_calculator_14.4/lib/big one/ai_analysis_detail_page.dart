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
  final TextEditingController _controller = TextEditingController(); // Add this line to control the text in the TextField

  @override
  Widget build(BuildContext context) {
    String response = '';
    String userQuestion = ''; // Add this line to hold the user's questio
    DateTime createdAt;
    String parentId = '';
    parentId = widget.replyData['parentMessageId']; // Add this line to retrieve the parentMessageId

    try {
      createdAt = (widget.replyData['status']['created_at'] as Timestamp).toDate();
      response = widget.replyData['response'] ?? 'No response';
      userQuestion = widget.replyData['question'] ?? 'No question'; // Add this line to retrieve the user's question

    } catch (e) {
      // If an error occurs, the fields are populated with an error message
      createdAt = DateTime.now();
      response = '아직 GPT가 요청에 응답 중입니다...잠시 후 다시 들어와주세요.';
      userQuestion = 'No question'; // Add this line in case of an error
    }

    return Scaffold(
      appBar: const MyAppBar(title: 'AI 분석 세부사항'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Text('응답 시간: $createdAt', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16.0),
            Text('내 질문: $userQuestion', style: Theme.of(context).textTheme.titleLarge), // Add this line to display the user's question
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
              padding: const EdgeInsets.all(10.0),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: '여기에 추가 질문을 입력하세요...',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                // The onPressed function should contain the logic to send the user's new question to the backend.
                // The parentId should be included in this new question to allow for tracking the conversation.
                // Once the question is sent, you should probably clear the text in the TextField by calling _controller.clear()
              },
            ),
          ],
        ),
      ),
    );
  }
}





