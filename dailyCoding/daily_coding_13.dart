class Solution {
  int majorityElement(List<int> nums) {
    nums.sort();
    return nums[nums.length ~/2];
  }
}


//이거 sort로 정렬했을 때, 최빈값이 있다면 분명 전체 리스트의 절반을 차지할테니까, 이걸 이용하면 되지 않을까? 무조건 중간에 있는 원소는 최빈값일테니까. 9:08 클리어