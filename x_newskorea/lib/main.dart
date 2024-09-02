import 'package:flutter/material.dart';
import 'news_home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,

  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'X-News Korea',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.white, // 배경색을 설정
      ),
      home: NewsHomePage(),
    );
  }
}
// 현재 브랜치가 변경된 게 맞다면, 이 주석은 새 브랜치에만 있어야 함.
