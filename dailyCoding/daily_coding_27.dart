//class Solution { // 첫번째 방법은 sublist, reduce, sort 등의 시간이 오래 걸리는 메서드를 사용해서 작동은 하지만 오래 걸린다.
//double findMaxAverage(List<int> nums, int k) {
//List<double> average_list = [];
//for(int i = 0; i < nums.length-(k-1); i++) {
// average_list.add(nums.sublist(i, i+k).reduce((a, b) => a+b) / k);
//}
//average_list.sort();
//return average_list.last;
//}
//}
// 이 방법은 답이 나오긴 하는데 시간이 너무 오래걸려서 제출하면 타임 리미트가 나온다..슬라이딩 윈도우를 써보자.

class Solution {
  double findMaxAverage(List<int> nums, int k) {
    int max_sum = 0;
    // 첫 번째 기본값을 넣자.
    for(int i=0; i<k;i++){
      max_sum += nums[i];
    }
    // 둘의 값을 같게 초기화 시키자.
    int now_sum = max_sum;
    //한칸 전진할 때 마다 다음 값을 넣고 이전 값을 뺀다.
    for(int i = 1; i < nums.length-(k-1); i++) {
      now_sum = now_sum + nums[i+(k-1)] - nums[i-1];

      if(max_sum < now_sum) {
        max_sum = now_sum;
      }
    }
    return max_sum / k; // 마지막에 나눠서 리턴하면 시간도 메모리도 아낀다;
  }
}