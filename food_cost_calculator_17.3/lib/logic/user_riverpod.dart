import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userEmailProvider = StreamProvider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final uid = user.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((snapshot) {
      return snapshot.data()?['email'] ?? Stream.value(null);
    });
  } else {
    // 로그인되지 않은 경우, null 반환
    return Stream.value(null);
  }
});


final userDisplayNameProvider = StreamProvider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final uid = user.uid;

    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((snapshot) {
      return snapshot.data()?['userDisplayName'] ?? Stream.value(null);
    });
  } else {
    // 로그인되지 않은 경우, null 반환
    return Stream.value(null);
  }
});
