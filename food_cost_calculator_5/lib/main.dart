import 'package:flutter/material.dart';
import '/cost_input_page.dart';
import '/cost_calculator_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'language.dart'; // Language 클래스가 있는 파일을 import 합니다.

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  incrementLaunchCount();

  runApp(const ProviderScope(child: MyApp())); // Riverpod의 ProviderScope로 MyApp을 감쌉니다.
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider) ?? const Locale('en');
    final appLocalizations = AppLocalizations.of(context);

    return MaterialApp(
      title: appLocalizations?.costInputPage ?? '',
      // Check for null value before accessing properties
      initialRoute: "/cost-input",
      theme: ThemeData(
        primaryColor: Colors.blueGrey,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey)
            .copyWith(secondary: Colors.orange),
      ),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        "/cost-input": (context) => const CostInputPage(),
        "/calculate": (context) {
          final args = ModalRoute
              .of(context)!
              .settings
              .arguments as Map<String, dynamic>;
          return CostCalculatorPage(costList: args['costList'],
              quantity: args['quantity'],
              foodPrice: args['itemPrice']);
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

