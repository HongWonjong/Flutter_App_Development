class Solution {
  bool isHappy(int n) {
    for(int i =0; i < 10; i++) { //이거 사이클 감지 해야 하는건 아는데 그냥 10번 반복문 넣어서 해봤습니다 ㅎㅎ;
      n = n.toString().split('').map((n) => int.parse(n)).map((n) => n * n).reduce((a,b) => a+b);
      if(n == 1) {
        return true;
      }
    }
    return false;
  }
}