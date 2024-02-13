import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:website/style/language.dart';


Future<void> showDeleteConfirmationDialog(BuildContext context, String docName) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('삭제 확인'),
        content: Text('$docName 기록을 삭제하시겠습니까?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // "삭제" 버튼 클릭 시 실행되는 함수 호출
              deleteDoc(context, docName);
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
            child: Text('삭제'),
          ),
        ],
      );
    },
  );
}


void deleteDoc(BuildContext context, String docType) async {
  try {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference discussionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('discussions');

    String docId;
    if (docType == FunctionLan.geminiDoc) {
      docId = FunctionLan.geminiDoc;
    } else if (docType == FunctionLan.gpt35Doc) {
      docId = FunctionLan.gpt35Doc;
    } else {
      // 유효하지 않은 docType이면 함수 종료
      return;
    }

    // 해당 문서의 messages 하위 컬렉션 삭제
    await discussionsRef
        .doc(docId)
        .collection('messages')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference.delete();
      });
    });

    // 해당 문서 삭제
    await discussionsRef.doc(docId).delete();

    // 삭제 성공 시 SnackBar로 알림
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$docType 삭제 완료'),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    // 삭제 실패 시 SnackBar로 알림
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$docType 삭제 실패: $e'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
