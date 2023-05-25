import 'package:flutter/material.dart';
import '/cost_input_page.dart';
import '/cost_calculator_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  incrementLaunchCount();

  runApp(MaterialApp(
    title: "원가 계산기",
    initialRoute: "/cost-input",
    theme: ThemeData(
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey).copyWith(secondary: Colors.orange),
    ),
    routes: {
      "/cost-input": (context) => const CostInputPage(),
      "/calculate": (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return CostCalculatorPage(costList: args['costList'], quantity: args['quantity'], foodPrice: args['itemPrice']);
      },
    },
  ));
}

// 앱 실행 횟수를 증가시키는 함수
void incrementLaunchCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int launchCount = prefs.getInt('launchCount') ?? 0;
  await prefs.setInt('launchCount', launchCount + 1);
}
