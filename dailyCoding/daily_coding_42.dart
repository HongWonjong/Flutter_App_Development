
class Solution {
  String intToRoman(int num) {
    // 로마자 문자와 대응하는 숫자를 인덱스가 같도록 2개의 리스트를 만듬.
    List<String> symbols = [
      "M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"
    ];
    List<int> values = [
      1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1
    ]
    // 로마열 문자열을 저장할 변수 초기화
    String result = '';

    // 큰 값부터 작은 값까지 차례대로 처리를 하며, 각 로마자 숫자에 대하여 while문을 실시한다.
    for (int i = 0; i < symbols.length; i++) {
      while (num >= values[i]) {
        result += symbols[i];
        num -= values[i];
      }
    }

    return result;
  }
}
