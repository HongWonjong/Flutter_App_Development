class Solution {
  List<String> letterCombinations(String digits) {
    if (digits.isEmpty) {
      return [];
    }
    final phoneMap = ['abc', 'def', 'ghi', 'jkl', 'mno', 'pqrs', 'tuv', 'wxyz'];
    final output = <String>[];
    _backtrack(output, phoneMap, digits, 0, '');
    return output;
  }

  void _backtrack(List<String> output, List<String> phoneMap, String digits,
      int index, String current) {
    if (index == digits.length) {
      output.add(current);
      return;
    }
    final digit = int.parse(digits[index]) - 2;
    final letters = phoneMap[digit];
    for (var letter in letters.split('')) {
      _backtrack(output, phoneMap, digits, index + 1, current + letter);
    }
  }
}