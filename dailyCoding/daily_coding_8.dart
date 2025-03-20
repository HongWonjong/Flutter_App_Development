class Solution {
  void merge(List<int> nums1, int m, List<int> nums2, int n) {
    int k=0;
    if (nums2.isEmpty) {
      return;
    }

    if(n ==0) {
      return;
    }



    for(int i = m; i < nums1.length; i++) {

      if(nums1[i] ==0) {
        nums1[i] += nums2[k];
        k++;
      }
    }
    nums1.sort();

  }
}