import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendPromptToServerlessFunction({
  required String uid,
  required String text,
  required String model,
}) async {
  final uri = Uri.parse('YOUR_SERVERLESS_FUNCTION_ENDPOINT'); // 서버리스 함수의 엔드포인트
  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'uid': uid,
      'text': text,
      'model': model,
    }),
  );

  if (response.statusCode == 200) {
    // 성공적으로 응답을 받음
    print('Serverless function responded: ${response.body}');
  } else {
    // 오류 처리
    print('Failed to call serverless function');
  }
}
