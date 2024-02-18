import 'package:flutter/material.dart';
import '../component/custom_app_bar.dart';
import '../function/google_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website/function/riverpod_setting.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class MyApp extends ConsumerWidget {
  MyApp({Key? key}) : super(key: key);
  final AuthFunctions authFunctions = AuthFunctions();


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.maybeWhen(
      data: (user) => user != null, // User 객체가 null이 아니면 로그인한 것으로 간주
      orElse: () => false, // 그 외의 경우에는 로그인하지 않은 것으로 간주
    );
    // 구글 어널리틱스 관련 코드
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
    FirebaseAnalyticsObserver(analytics: analytics);
    //

    return MaterialApp(
      navigatorObservers: <NavigatorObserver>[observer],

      home: Scaffold(
        resizeToAvoidBottomInset: true, // 키보드가 화면에 나타날 때 위젯이 밀리며 생기는 UI 문제를 해결할 수 있다.
        appBar:  const CustomAppBar(),
        body: isLoggedIn // 로그인 상태에 따라 조건부 렌더링
            ? const MainScreen()
            : const LoginScreen()
        ),
      );
  }
}





