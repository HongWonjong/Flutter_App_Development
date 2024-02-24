import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'big one/cost_input_page.dart';
import 'big one/cost_calculator_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'logic/user_riverpod.dart';
import 'package:food_cost_calculator_3_0/big one/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase 인증 에러: $e");
  }


  // Firebase App Check 초기화
  FirebaseAppCheck.instance.activate();

  // Mobile Ads 초기화
  MobileAds.instance.initialize();

  await loadPreferredLanguage();
  incrementLaunchCount();

  runApp(const ProviderScope(child: MyApp()));
}


Future<void> loadPreferredLanguage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? preferredLanguage = prefs.getString('preferredLanguage');
  if (preferredLanguage != null) {
    Locale locale = Locale(preferredLanguage);
    // Save the preferred language in a globally accessible variable.
    preferredLocale = locale;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier(preferredLocale ?? const Locale('en'));
});

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier(Locale state) : super(state);

  void switchToLanguage(String languageCode) {
    state = Locale(languageCode);
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    final appLocalizations = AppLocalizations.of(context);

    String initialRoute = "/login";

    return MaterialApp(
      title: appLocalizations?.costInputPage ?? '',
      initialRoute: initialRoute,
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
        "/login": (context) => const LoginPage(), // Add this
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

void incrementLaunchCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int launchCount = prefs.getInt('launchCount') ?? 0;
  await prefs.setInt('launchCount', launchCount + 1);
}

Locale? preferredLocale;









