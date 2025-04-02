class Solution {
  bool containsNearbyDuplicate(List<int> nums, int k) {
    Map <int, int> num_index = {};
    for(int i = 0; i < nums.length; i++) {
      if(num_index.containsKey(nums[i])&&(i - num_index[nums[i]]!).abs() <= k) {
        return true;
      } else {
        num_index[nums[i]] = i;
      }
    }
    return false;
  }
}
