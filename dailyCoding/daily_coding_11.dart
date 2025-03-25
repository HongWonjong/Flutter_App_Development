class Solution {
  bool isPalindrome(String s) {
    String sss = s.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    int half_length = sss.length ~/ 2;
    for(int i = 0; i < half_length; i++) {
      if(sss[i] != sss[sss.length -i -1]) {
        return false;
      }
    }
    return true;
  }
}
// 이제 이걸 어떻게 비교할까인데, 길이를 2로 나눈 정수 몫 만큼 앞과 끝을 비교하면 될 듯. 중간은 있든 없든 상관 없으니까. 그리고 정규식으로 바꾸자.