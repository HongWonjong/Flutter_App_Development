import 'package:cloud_functions/cloud_functions.dart';


Future<String> fetchSecretValue() async {
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getSecretValue');
  final response = await callable.call();
  return response.data['secretValue'];
}

Future<String> fetchGptApiKey() async {
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getSecretValue');
  final response = await callable.call();
  return response.data['gpt35SecretValue'];
}