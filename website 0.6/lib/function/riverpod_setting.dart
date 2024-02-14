import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// riverpod_setting.dart 또는 앱의 상태 관리를 담당하는 파일에 추가

final authStateProvider = StateProvider<bool>((ref) {
  // 초기 상태 설정. 기본적으로 로그인 상태는 false로 설정
  return false;
});

final userEmailProvider = StreamProvider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final uid = user.uid;

    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((snapshot) {
      return snapshot.data()?['email'] ?? '';
    });
  } else {
    // 로그인되지 않은 경우, null 반환
    return Stream.value(null);
  }
});

final userGPProvider = StreamProvider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final uid = user.uid;

    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((snapshot) {
      return snapshot.data()?['GeminiPoint'] ?? '';
    });
  } else {
    // 로그인되지 않은 경우, null 반환
    return Stream.value(null);
  }
});
