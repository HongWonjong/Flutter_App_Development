import 'package:flutter_riverpod/flutter_riverpod.dart';

// 언어 쌍을 저장하는 클래스
class LanguagePair {
  final String? sourceLanguage; // 음성 언어
  final String? targetLanguage; // 번역 언어

  LanguagePair({this.sourceLanguage, this.targetLanguage});

  // 새로운 값으로 업데이트된 복사본 반환
  LanguagePair copyWith({String? sourceLanguage, String? targetLanguage}) {
    return LanguagePair(
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }
}

// 언어 쌍을 관리하는 StateProvider
final languageProvider = StateProvider<LanguagePair>((ref) {
  return LanguagePair(sourceLanguage: null, targetLanguage: null);
});

// 언어 선택 완료 여부를 체크하는 Provider
final isLanguageSelectedProvider = Provider<bool>((ref) {
  final languagePair = ref.watch(languageProvider);
  return languagePair.sourceLanguage != null && languagePair.targetLanguage != null;
});