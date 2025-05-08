class Solution {
  int lengthOfLongestSubstring(String s) {
    // 가드패턴
    if (s.isEmpty) return 0; // 빈 문자열 처리
    if (s.length == 1) return 1; // 길이 1인 문자열 처리


    int subStringLength = 1; // 최대 고유 문자열 길이
    List<String> longestSubstring = []; // 현재 고유 문자열

    for (int i = 0; i < s.length; i++) {
      String currentChar = s[i];

      // 현재 문자가 longestSubstring에 있는지 확인
      int duplicateIndex = longestSubstring.indexOf(currentChar);

      if (duplicateIndex != -1) {
        // 중복이 발견된 경우, 최대 길이 갱신
        if (longestSubstring.length > subStringLength) {
          subStringLength = longestSubstring.length;
        }
        // 중복 문자 이후부터 새로운 문자열 시작
        longestSubstring = longestSubstring.sublist(duplicateIndex + 1);
        longestSubstring.add(currentChar);
      } else {
        // 중복이 없으면 현재 문자 추가
        longestSubstring.add(currentChar);
      }
    }

    // 최종적으로 리스트 길이 확인
    if (longestSubstring.length > subStringLength) {
      subStringLength = longestSubstring.length;
    }

    return subStringLength;
  }
}
