bool wordPattern(String pattern, String s) {
  List<String> words = s.split(' ');

  if (pattern.length != words.length) return false;

  Map<String, String> charToWord = {};
  Map<String, String> wordToChar = {};

  // charToWord = { a : 'cat' }
  // wordToChar = { cat : 'a' }

// pattern == 'abba'
// s == 'cat dog dog cat'
  for (int i = 0; i < pattern.length; i++) {
    String char = pattern[i];
    String word = words[i];

    if (charToWord.containsKey(char)) {
      if (charToWord[char] != word) return false;
    } else {
      charToWord[char] = word;
    }

    if (wordToChar.containsKey(word)) {
      if (wordToChar[word] != char) return false;
    } else {
      wordToChar[word] = char;
    }
  }

  return true;
}