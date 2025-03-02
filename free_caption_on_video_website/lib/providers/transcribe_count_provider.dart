import 'package:flutter_riverpod/flutter_riverpod.dart';


final transcribeCountProvider = StateProvider<Map<String, dynamic>?>((ref) {
  return null; // 초기값 null (데이터 미로드)
});

// today를 앱 시작 시 한 번만 계산
final todayProvider = Provider<String>((ref) {
  return DateTime.now().toIso8601String().split('T')[0];
});