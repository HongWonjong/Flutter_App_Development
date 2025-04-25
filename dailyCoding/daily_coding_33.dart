class Solution {
  String gcdOfStrings(String str1, String str2) {
    // 가드패턴 1: 첫 글자와 마지막 글자가 다른 경우 공약 문자열이 없음
    if (str1[0] != str2[0] || str1[str1.length - 1] != str2[str2.length - 1]) {
      return "";
    }

    // 가드패턴 2: str1 + str2와 str2 + str1가 같은지 확인
    if ((str1 + str2) != (str2 + str1)) {
      return "";
    }

    // 유클리드 알고리즘으로 두 문자열 길이의 최대 공약수 계산
    int gcdLength = _gcd(str1.length, str2.length);

    // 최대 공약수 길이만큼의 접두사를 반환
    return str1.substring(0, gcdLength);
  }

  // (유클리드 알고리즘으로 최대공약수 구하기)
  int _gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }
}
// 공약수를 만족하려면 어떻게 해야 할까?
// 두 문자열의 첫 글자가 다른 경우: 공약수가 있을수가 없다.
// 두 문자열의 마지막 글자가 다른 경우: 공약수가 있을수가 없다.
// str1 < str2인 경우: str1이 반복패턴이거나, 반복패턴의 조합이다.
// str1 > str2인 경우: str2가 반복패턴이거나, 반복패턴의 조합이다.
// 가드패턴으로 첫 글자 끝 글자가 같은지 확인하고, 문자열 1+2와 2+1이 같다면 반복 가능한 패턴들이므로
// 최대 공약수가 존재한다.
