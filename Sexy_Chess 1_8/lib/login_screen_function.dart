import 'package:flutter/material.dart';

void showSignUpDialog(BuildContext context, VoidCallback handleSignUp) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        clipBehavior: Clip.none,
        title: const Text('이메일로 로그인'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  // 이메일 값 업데이트
                },
                // TextField의 속성들 추가
              ),
              TextField(
                onChanged: (value) {
                  // 비밀번호 값 업데이트
                },
                // TextField의 속성들 추가
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: handleSignUp,
            child: const Text('로그인'),
          ),
        ],
      );
    },
  );
}
