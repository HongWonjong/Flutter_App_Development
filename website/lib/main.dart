import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'component/custom_app_bar.dart';
import 'component/body_part.dart';

void main() {
  html.window.onBeforeUnload.listen((event) {
    // 앱 종료 시 실행될 코드
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(),
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: BodyPage(
                      text: '안녕하세요, 웹사이트를 꾸며보는 중입니다! - Body Page 1',
                    ),
                  ),
                  // 나머지 Body 페이지도 추가
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: BodyPage(
                      text: '다른 내용을 추가하세요! - Body Page 2',
                    ),
                  ),
                  // 나머지 Body 페이지도 추가
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}