import 'dart:math';

class WordManager {
  final List<String> _words = [];
  final Random _random = Random();

  List<String> get words => List.unmodifiable(_words);

  void addWord(String word) {
    _words.add(word);
  }

  void removeWord(int index) {
    if (index >= 0 && index < _words.length) {
      _words.removeAt(index);
    }
  }

  String getRandomWord() {
    if (_words.isNotEmpty) {
      int randomIndex = _random.nextInt(_words.length);
      String randomWord = _words[randomIndex];
      _words.removeAt(randomIndex);  // 목록에서 단어를 제거합니다.
      return randomWord;
    }
    return '';
  }
}
