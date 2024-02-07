import 'package:firebase_auth/firebase_auth.dart';
import 'riverpod_setting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 로그아웃 함수
Future<void> signOut(ProviderContainer container) async {
  try {
    // 파이어베이스 로그아웃
    await FirebaseAuth.instance.signOut();

    // Riverpod 인스턴스에서 데이터 초기화
    container.read(uidProvider).state = null;
    container.read(userEmailProvider).state = null;
    container.read(userGPProvider).state = null;

    // 여기에 다른 Riverpod 상태를 초기화하는 코드를 추가할 수 있습니다.

    print("로그아웃 성공");
  } catch (e) {
    print("로그아웃 에러: $e");
  }
}
