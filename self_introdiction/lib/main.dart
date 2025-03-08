import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'; // Riverpod 추가
import 'firebase_options.dart'; // FlutterFire CLI로 생성된 파일
import 'pages/room_page.dart'; // 방 페이지
import 'pages/home_page.dart'; // 메인 페이지

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    // ProviderScope로 앱 전체를 감쌈
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '팀 프로젝트 사이트',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _router, // 라우터 설정
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(title: '팀 프로젝트 사이트'),
    ),
    GoRoute(
      path: '/room/:key',
      builder: (context, state) {
        final String key = state.pathParameters['key']!;
        return RoomPage(roomKey: key);
      },
    ),
  ],
);