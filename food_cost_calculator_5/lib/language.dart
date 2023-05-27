import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:ui';

class Language extends StateNotifier<Locale> {
  Language() : super(const Locale('en', ''));

  void switchToEnglish() {
    state = const Locale('en', '');
  }

  void switchToKorean() {
    state = const Locale('ko', '');
  }
}

final languageProvider = StateNotifierProvider<Language, Locale>((ref) => Language());
