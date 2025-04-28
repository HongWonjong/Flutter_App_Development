class Solution {
  int tribonacci(int n) {
    if(n==0) return 0;

    if(n==1 || n==2) return 1;

    List<int> bonacci = [0, 1, 1];

    for(int i=3; i<=n; i++) {
      bonacci.add(bonacci[i-1]+bonacci[i-2]+bonacci[i-3]);
    }
    return bonacci[n];


  }
}