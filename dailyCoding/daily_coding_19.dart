class Solution {
  bool isAnagram(String s, String t) {
    // 길이가 다르면 애너그램이 될 수 없으므로 가드패턴 생성
    if (s.length != t.length) {
      return false;
    }

    // codeUnits으로 정렬 가능한 아스키 코드로 바꾼 후, 다시 리스트로 변환 후 정렬, ..캐스케이드 연산자를 통해 수정된 객체를 반환
    List<int> sUnits = s.codeUnits.toList()..sort();
    List<int> tUnits = t.codeUnits.toList()..sort();

    // 정렬된 리스트 비교를 통한 bool 리턴
    return sUnits.toString() == tUnits.toString();
  }
}