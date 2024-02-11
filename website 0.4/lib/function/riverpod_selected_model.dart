import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website/style/language.dart';

final selectedModelProvider = StateProvider<String>((ref) {
  // 초기값을 설정할 수 있습니다.
  return MainPageLan.modelNameGemini;
});
