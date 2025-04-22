class Solution {
  int minCostClimbingStairs(List<int> cost) {
    int n = cost.length;
    List<int> dp = List.filled(n+1,0); // dp[i]: 1번째 계단 까지의 최소 비용

    dp[0] = cost[0];
    dp[1] = cost[1];

    for (int i = 2; i < n;i++) {
      dp[i] = cost[i] + (dp[i-1] < dp[i-2] ? dp[i-1] : dp[i-2]);
    }

    return dp[n-1] < dp[n-2] ? dp[n-1] : dp[n-2];
  }
}