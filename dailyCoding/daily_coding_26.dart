class Solution {
  bool canPlaceFlowers(List<int> flowerbed, int n) {
    int count = 0; // 심을 수 있는 꽃의 개수, n과 비교하여 참거짓 리턴
    int length = flowerbed.length;

    for(int i =0; i < length; i++) {// 현재 인덱스와 -1, +1 인덱스를 검사하면 됨
      //현재 칸이 비어있는지 확인
      if(flowerbed[i] == 0 ){
        // 이전 칸이 비어있는지 확인(이전 칸이 없는 인덱스 0이라면 무조건 참)
        bool leftEmpty = (i==0) || flowerbed[i-1]==0;

        // 다음 칸이 비어있는지 확인(다음 칸이 없는 length-1 인덱스면 무조건 참)
        bool rightEmpty = (i==length-1) || flowerbed[i+1]==0;

        // 둘 다 참이라면 심을 수 있으므로 심고, count 추가
        if(leftEmpty && rightEmpty) {
          flowerbed[i] = 1;
          count++;
        }
      }

    }
    // n개를 심을 수 있으려면 count보다 같거나 작아야 하므로..
    return count >= n;

  }
}