class Solution {
  List<int> bit2List = [];
  List<int> countBits(int n) {
    if(n == 0){
      return [0];
    }
    for(int i =0; i <= n; i++) {
      // 일단 i를 이진수로 바꾸고, int로 바꾼 뒤 전부 다 더하면 1의 개수와 같다.
      bit2List.add(i.toRadixString(2).split("").map((n) => int.parse(n)).reduce((a, b) => a+b));
    }
    return bit2List;
  }
}