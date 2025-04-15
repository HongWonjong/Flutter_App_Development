class Solution {
  bool isSubsequence(String s, String t) {
    if(s.isEmpty) return true; // s가 빈 문자열인 경우 언제나 부분수열

    // 투 포인터 기법을 통해 풀어보자.
    int i = 0;
    for(int j =0; j < t.length; j++){
      if(i < s.length && s[i] == t[j]) {
        // i == s.length라면 부분수열을 이미 만족했으므로 종료, 그 이외에는 부분수열 확인
        i++;
      }
    }
    if(i == s.length) return true;
    return false;
  }
}
