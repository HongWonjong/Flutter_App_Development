class Solution {
  List<List<int>> threeSum(List<int> nums) {
    // 1. 배열 정렬
    nums.sort();
    List<List<int>> result = [];

    // 2. 배열 순회
    for (int i = 0; i < nums.length - 2; i++) {
      // 중복된 기준 값은 건너뜀
      if (i > 0 && nums[i] == nums[i - 1]) continue;

      int left = i + 1;
      int right = nums.length - 1;

      while (left < right) {
        int sum = nums[i] + nums[left] + nums[right];

        if (sum == 0) {
          result.add([nums[i], nums[left], nums[right]]);
          // 중복된 값 건너뜀
          while (left < right && nums[left] == nums[left + 1]) left++;
          while (left < right && nums[right] == nums[right - 1]) right--;
          left++;
          right--;
        } else if (sum < 0) {
          left++;
        } else {
          right--;
        }
      }
    }

    return result;
  }
}