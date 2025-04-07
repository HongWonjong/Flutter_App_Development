class Solution {
  void moveZeroes(List<int> nums) {
    int lastNonZeroIndex = 0;

    // 모든 비-0 요소를 배열의 앞부분으로 이동
    for (int i = 0; i < nums.length; i++) {
      if (nums[i] != 0) {
        nums[lastNonZeroIndex] = nums[i];
        lastNonZeroIndex++;
      }
    }
    // [1,3,12,3,12]

    // 나머지 요소를 0으로 설정
    for (int i = lastNonZeroIndex; i < nums.length; i++) {
      nums[i] = 0;
    }
    // [1,3,12,0,0]
  }
}