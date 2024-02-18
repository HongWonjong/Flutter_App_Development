import 'package:cloud_functions/cloud_functions.dart';

Future<String> fetchRecaptchaToken() async {
  // 리전을 명시적으로 지정
  HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'asia-northeast3').httpsCallable('getRecaptchaToken');
  final response = await callable.call();
  return response.data['secretValue'];
}
// region을 fetch 함수에서도 명시적으로 지정해주지 않으면, 아이오와에 있는 서버리스 함수에 접속하려고 한다.
Future<String> fetchGpt35ApiKey() async {
  // 리전을 명시적으로 지정
  HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'asia-northeast3').httpsCallable('getGpt35ApiKey');
  final response = await callable.call();
  return response.data['gpt35SecretValue'];
}
