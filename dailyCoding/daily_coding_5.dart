class Solution {
  List<int> copy_nums = [];
  int removeElement(List<int> nums, int val) { // [3, 2, 2, 3], 3
    for(int i = 0; i < nums.length; i++) {
      if (nums[i] != val) {
        copy_nums.add(nums[i]);
      }
    }
    for(int i = 0; i < copy_nums.length; i++) {
      nums[i] = copy_nums[i];
    }
    return copy_nums.length;
  }
}