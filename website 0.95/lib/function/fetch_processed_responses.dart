import 'package:cloud_firestore/cloud_firestore.dart';

// 이전에 한 질문들을 간소화 시켜놓은 컬렉션에서 문서들을 가져와서 시간 순으로 정리 해둔다.
Future<String> fetchProcessedResponses(String uid) async {
  CollectionReference responsesRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('processed_responses');
  QuerySnapshot querySnapshot = await responsesRef.orderBy('timestamp', descending: false).get(); // 타임스탬프 기준으로 정렬

  StringBuffer pastResponses = StringBuffer();
  for (var doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    pastResponses.writeln('{질문: ${data['question']}}');
    pastResponses.writeln('{응답: ${data['response']}}');
    pastResponses.writeln(','); // 구분선 추가
  }

  return pastResponses.toString();
}
