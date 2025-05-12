class Solution {
  int maxArea(List<int> height) {
    int left = 0;
    int right = height.length - 1;
    int maxArea = 0;

    while (left < right) {
      int currentHeight = min(height[left], height[right]);
      int currentArea = currentHeight * (right - left);
      maxArea = max(maxArea, currentArea);

      // 낮은 높이의 포인터를 움직여 더 높은 영역을 찾음
      if (height[left] < height[right]) {
        left++;
      } else {
        right--;
      }
    }

    return maxArea;
  }
}