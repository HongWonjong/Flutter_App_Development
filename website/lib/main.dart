import 'package:flutter/material.dart';
import 'dart:html' as html;

void main() {
  html.window.onBeforeUnload.listen((event) {
    // 앱 종료 시 실행될 코드
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('나만의 웹사이트입니다'),
          backgroundColor: Colors.blue, // 앱바 배경색
        ),
        body: Container(
          color: Colors.grey[200], // 배경색
          padding: const EdgeInsets.all(16.0),
          child: const Center(
            child: Text(
              '안녕하세요, 웹사이트를 꾸며보는 중입니다!',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        ),
      ),
    );
  }
}
