import 'package:flutter/material.dart';
import 'page/mainpage.dart'; // 메인 파일의 이름에 따라 수정
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'function/init_app.dart';


void main() async {
  await AppInitializer.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

