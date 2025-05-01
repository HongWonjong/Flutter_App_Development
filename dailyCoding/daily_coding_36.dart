class Solution {
  List<bool> kidsWithCandies(List<int> candies, int extraCandies) {
    // 일단 최대 캔디값을 찾아야 함. reduce를 이용하면 모든 요소들을 비교할 수 있음
    int maxCandies = candies.reduce((a, b) => a > b ? a : b);

    // 각 요소의 사탕 수에 extracandies를 더했을 때 maxcandies보다 크거나 같은지 확인하여
    // 배열을 만듬
    List<bool> result = [];
    for(int candy in candies) {
      result.add(candy + extraCandies >= maxCandies);
    }
    return result;
  }
}