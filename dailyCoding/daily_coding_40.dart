class Solution {
  String convert(String s, int numRows) {
    if (numRows == 1 || numRows >= s.length) return s;

    StringBuffer result = StringBuffer();
    int n = s.length;
    int cycleLen = 2 * (numRows - 1); // 한 사이클의 길이 측정

    for (int row = 0; row < numRows; row++) {
      for (int i = 0; i + row < n; i += cycleLen) {
        // 첫 번째 문자 (각 행의 기본 인덱스)
        result.write(s[i + row]);

        // 중간 행의 경우, 두 번째 문자 추가
        if (row > 0 && row < numRows - 1 && i + cycleLen - row < n) {
          result.write(s[i + cycleLen - row]);
        }
      }
    }

    return result.toString();
  }
}