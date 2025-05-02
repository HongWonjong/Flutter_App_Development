class Solution {
  int largestAltitude(List<int> gain) {
    int maxAltitude = 0; // 최댓값 추적
    int currentAltitude = 0; // 현재 고도

    for (int change in gain) {
      currentAltitude += change; // 고도 변화를 적용
      maxAltitude = maxAltitude > currentAltitude ? maxAltitude : currentAltitude; // 최댓값 갱신
    }

    return maxAltitude;
  }
}