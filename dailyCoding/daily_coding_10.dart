class Solution {
  int maxProfit(List<int> prices) {// [ 2, 3, 6, 2, 3]
    if (prices.length < 2) return 0;

    int minPrice = prices[0];
    int maxProfit = 0;

    for (int i = 1; i < prices.length; i++) {
      if (prices[i] < minPrice) {
        minPrice = prices[i];
      }
      int currentProfit = prices[i] - minPrice;
      if (currentProfit > maxProfit) {
        maxProfit = currentProfit;
      }
    }

    return maxProfit;
  }
}