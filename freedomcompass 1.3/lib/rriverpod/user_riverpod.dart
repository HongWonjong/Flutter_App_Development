import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final uidProvider = Provider<String>((ref) {
  String myuid = FirebaseAuth.instance.currentUser!.uid;
  return myuid;
});

final userEmailProvider = FutureProvider.autoDispose<String>((ref) async {
  final uid = ref.watch(uidProvider);

  // Firestore에서 해당 UID의 사용자 정보 가져오기
  final userDoc = await FirebaseFirestore.instance.collection('user').doc(uid).get();

  // 사용자 정보에서 이메일 가져오기
  final userEmail = userDoc.data()?['user_email'] ?? ''; // 예외 처리를 통한 안전한 접근

  return userEmail;
});