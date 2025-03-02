import 'package:cloud_firestore/cloud_firestore.dart';

class TranscribeCountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'transcribe_counts';
  static const String _docId = 'stats';
  static const String _secretKey = 'SE135r3f213f'; // 직접 하드코딩
  Future<void> incrementTranscribeCount() async {
    try {
      final transcribeRef = _firestore.collection(_collectionName).doc(_docId);
      final date = DateTime.now().toIso8601String().split('T')[0];

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(transcribeRef);
        if (!snapshot.exists) {
          transaction.set(transcribeRef, {
            'total_count': 1,
            'daily_counts': {date: 1},
            'secret_key': _secretKey,
          });
        } else {
          final data = snapshot.data()!;
          final totalCount = (data['total_count'] as int? ?? 0) + 1;
          final dailyCounts = Map<String, dynamic>.from(data['daily_counts'] as Map? ?? {});
          dailyCounts[date] = (dailyCounts[date] as int? ?? 0) + 1;

          transaction.update(transcribeRef, {
            'total_count': totalCount,
            'daily_counts': dailyCounts,
            'secret_key': _secretKey,
          });
        }
      });
    } catch (e) {
      // 오류 발생 시 로그만 남기고 무시
      print('[TranscribeCountService] Failed to increment count: $e');
      // 여기서는 아무 동작도 하지 않음 (기능 제외)
    }
  }

  Stream<DocumentSnapshot> getTranscribeCounts() {
    try {
      return _firestore.collection(_collectionName).doc(_docId).snapshots();
    } catch (e) {
      // 오류 발생 시 빈 스트림 반환
      print('[TranscribeCountService] Failed to get counts: $e');
      return const Stream.empty();
    }
  }
}