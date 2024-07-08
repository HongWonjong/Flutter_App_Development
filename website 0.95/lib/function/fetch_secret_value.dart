import 'package:cloud_functions/cloud_functions.dart';

Future<String> fetchGpt35ApiKey() async {
  try {
    // 리전을 명시적으로 지정
    HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'asia-northeast3').httpsCallable('getGpt35ApiKey');
    final response = await callable.call();
    return response.data['gpt35SecretValue'];
  } catch (e, stackTrace) {
    // 오류 로깅
    print('fetchGpt35ApiKey 오류: $e');
    print('Stack Trace: $stackTrace');
    return "";
  }
}
