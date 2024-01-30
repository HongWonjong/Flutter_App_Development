// memo_creating_function.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freedomcompass/function/navigator.dart';
import 'package:freedomcompass/page/main_page.dart';

void saveMemo(String memoText, BuildContext context) {
  // 현재 로그인한 사용자의 UID 가져오기
  String uid = FirebaseAuth.instance.currentUser?.uid ?? "";

  // contents 내용이 비어 있으면 저장 생략
  if (memoText.trim().isEmpty) {
    NavigatorHelper.goToPage(context, const MainPage());
    return;
  }

  // 현재 시간을 timestamp로 가져오기
  Timestamp currentTime = Timestamp.now();

  // Firestore에 데이터 추가
  FirebaseFirestore.instance.collection('user').doc(uid).collection('memoes').add({
    'contents': memoText,
    'createdTime': currentTime,
    'writer': uid,
  }).then((value) {
    NavigatorHelper.goToPage(context, const MainPage());
  }).catchError((error) {
  });
}



