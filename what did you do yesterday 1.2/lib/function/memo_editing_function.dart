// memo_editing_function.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freedomcompass/function/navigator.dart';
import 'package:freedomcompass/page/main_page.dart';
import 'package:freedomcompass/page/edit_memo_page.dart';

void editMemo(String memoId, String updatedMemoText, BuildContext context) {
  // 현재 로그인한 사용자의 UID 가져오기
  String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  Timestamp currentTime = Timestamp.now();

  // 해당 메모의 내용을 업데이트
  FirebaseFirestore.instance.collection('user').doc(uid).collection('memoes').doc(memoId).update({
    'contents': updatedMemoText,
    'lastEditedTime': currentTime,
  }).then((_) {
    print('메모가 성공적으로 수정되었습니다.');
    NavigatorHelper.goToPage(context, const MainPage());
  }).catchError((error) {
    print('메모 수정 중 오류 발생: $error');
  });
}
