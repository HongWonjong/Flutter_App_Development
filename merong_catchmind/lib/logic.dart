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

class ParticipantManager {
  final List<String> _participants = [];
  final Map<String, int> _scores = {};

  List<String> get participants => List.unmodifiable(_participants);
  Map<String, int> get scores => Map.unmodifiable(_scores);

  void addParticipant(String name) {
    if (name.isNotEmpty && !_participants.contains(name)) {
      _participants.add(name);
      _scores[name] = 0;
    }
  }

  void increaseScore(String name) {
    if (_scores.containsKey(name)) {
      _scores[name] = (_scores[name] ?? 0) + 1;
    }
  }

  void decreaseScore(String name) {
    if (_scores.containsKey(name)) {
      _scores[name] = (_scores[name] ?? 0) - 1;
    }
  }
}
