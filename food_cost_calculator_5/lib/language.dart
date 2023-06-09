import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

class Language extends StateNotifier<Locale> {
  Language() : super(const Locale('en', ''));

  void switchToEnglish() {
    state = const Locale('en', '');
  }

  void switchToKorean() {
    state = const Locale('ko', '');
  }

  void switchToMandarin() {
    state = const Locale('zh', '');
  }

  void switchToSpanish() {
    state = const Locale('es', '');
  }

  void switchToJapanese() {
    state = const Locale('ja', '');
  }

  void switchToRussian() {
    state = const Locale('ru', '');
  }
  void switchToPortuguese() {
    state = const Locale('pt', '');
  }
}

final languageProvider = StateNotifierProvider<Language, Locale>((ref) => Language());


