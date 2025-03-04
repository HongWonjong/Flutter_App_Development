// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 방 데이터 스트림 가져오기
  Stream<DocumentSnapshot> getRoomStream(String roomKey) {
    return _firestore.collection('rooms').doc(roomKey).snapshots();
  }

  // 새로운 방 생성
  Future<void> createRoom(String roomKey) async {
    await _firestore.collection('rooms').doc(roomKey).set({
      'key': roomKey,
      'widgets': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 위젯 추가
  Future<void> addWidget(String roomKey, Map<String, dynamic> widgetData) async {
    await _firestore.collection('rooms').doc(roomKey).update({
      'widgets': FieldValue.arrayUnion([widgetData]),
    });
  }

  // 위젯 삭제
  Future<void> removeWidget(String roomKey, Map<String, dynamic> widgetData) async {
    await _firestore.collection('rooms').doc(roomKey).update({
      'widgets': FieldValue.arrayRemove([widgetData]),
    });
  }
}