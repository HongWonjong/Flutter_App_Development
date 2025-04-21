class Solution {
  int pivotIndex(List<int> nums) {
    int totalSum = nums.reduce((a, b) => a + b);
    int leftSum = 0;
    Map <int, int> index_sumleft = {};

    for(int i =0; i< nums.length; i++) {
      // 각 요소마다 맵에 왼쪽 합을 넣으면 됨, 넣고 현재 요소도 leftsum에 추가
      // 추가로 해당 인덱스가 왼쪽 합이 딱 절반이면 리턴
      index_sumleft[i] = leftSum;
      if(leftSum * 2== totalSum - nums[i]) {
        return i;
      }
      leftSum += nums[i];
    }

    return -1;
  }
}
// 이걸 어떻게 구현하지? 일단 리스트의 전체 합을 구하고, 요소 기준 왼쪽의 합을 각 요소별로 구해서 맵에 저장해두자.
// 여러 개 있으면 가장 왼쪽에 있는걸 찾으라고 했으니, 그냥 가장 처음 왼쪽의 합이 전체 합의 절반이 되는걸 찾으면 되는 듯.