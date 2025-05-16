class Solution {
  int jump(List<int> nums) {
    int n = nums.length;
    if (n <= 1) return 0;

    int jumps = 0;
    int currEnd = 0;
    int nextEnd = 0;

    for (int i = 0; i < n - 1; i++) {
      nextEnd = nextEnd > i + nums[i] ? nextEnd : i + nums[i];

      if (i == currEnd) {
        jumps++;
        currEnd = nextEnd;

        if (currEnd >= n - 1) break;
      }
    }

    return jumps;
  }
}