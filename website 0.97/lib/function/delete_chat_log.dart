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
            onPressed: () async {
              // "삭제" 버튼 클릭 시 실행되는 함수 호출
              await deleteDoc(context, docName);
              await deleteCommandDoc(context, docName);
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
            child: Text('삭제'),
          ),
        ],
      );
    },
  );
}

Future<void> deleteDoc(BuildContext context, String docType) async {
  try {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference discussionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('discussions');

    String? docId;
    if (docType == FunctionLan.geminiDoc) {
      docId = FunctionLan.geminiDoc;
    } else if (docType == FunctionLan.gpt35Doc) {
      docId = FunctionLan.gpt35Doc;
    } else if (docType == FunctionLan.gpt4Doc) {
      docId = FunctionLan.gpt4Doc;
    } else if (docType == FunctionLan.palmDoc) {
      docId = FunctionLan.palmDoc;
    } else if (docType == FunctionLan.fibiDoc) {
      docId = FunctionLan.fibiDoc;
    } else if (docType == ExtendedfunctionLan.gpt35Doc) {
      docId = ExtendedfunctionLan.gpt35Doc;
    } else {
      docId = FunctionLan.gpt35VTuberDoc;
    }

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

Future<void> deleteCommandDoc(BuildContext context, String docType) async {
  try {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference discussionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('discussions');

    String? docId;
    if (docType == FunctionLan.geminiDoc) {
      docId = FunctionLan.geminiDoc;
    } else if (docType == FunctionLan.gpt35Doc) {
      docId = FunctionLan.gpt35Doc;
    } else if (docType == FunctionLan.gpt4Doc) {
      docId = FunctionLan.gpt4Doc;
    } else if (docType == FunctionLan.palmDoc) {
      docId = FunctionLan.palmDoc;
    } else if (docType == FunctionLan.fibiDoc) {
      docId = FunctionLan.fibiDoc;
    } else if (docType == ExtendedfunctionLan.gpt35Doc) {
      docId = ExtendedfunctionLan.gpt35Doc;
    } else {
      docId = FunctionLan.gpt35VTuberDoc;
    }

    // messages 하위 컬렉션 삭제
    QuerySnapshot messagesSnapshot = await discussionsRef
        .doc(docId)
        .collection('commands')
        .get();
    for (DocumentSnapshot document in messagesSnapshot.docs) {
      await document.reference.delete();
    }



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

