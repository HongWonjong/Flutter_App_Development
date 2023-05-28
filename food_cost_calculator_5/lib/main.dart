import 'package:flutter/material.dart';
import '/cost_input_page.dart';
import '/cost_calculator_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language.dart'; // Language 클래스가 있는 파일을 import 합니다.

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  incrementLaunchCount();

  runApp(const ProviderScope(child: MyApp())); // Riverpod의 ProviderScope로 MyApp을 감쌉니다.
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider); // 현재 언어 설정을 가져옵니다.

    return MaterialApp(
      title: "원가 계산기",
      initialRoute: "/cost-input",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey).copyWith(secondary: Colors.orange),
      ),
      locale: locale, // 언어 설정을 MaterialApp에 연결합니다.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ko', ''),
      ],
      routes: {
        "/cost-input": (context) => CostInputPage(),
        "/calculate": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CostCalculatorPage(costList: args['costList'], quantity: args['quantity'], foodPrice: args['itemPrice']);
        },
      },
    );
  }
}

// 앱 실행 횟수를 증가시키는 함수
void incrementLaunchCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int launchCount = prefs.getInt('launchCount') ?? 0;
  await prefs.setInt('launchCount', launchCount + 1);
}

