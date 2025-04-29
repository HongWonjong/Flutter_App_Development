class Solution {
  bool uniqueOccurrences(List<int> arr) {
    int length = arr.length; // 미리 변수에 할당하여 메모리를 줄여볼까
    if(length ==0) return true;

    Map<int, int> number_frequency = {};

    for(int i=0; i<length; i++) {
      number_frequency[arr[i]] = (number_frequency[arr[i]] ?? 0) + 1;
    }

    //set으로 변환하면 중복되는 빈도의 여부를 알 수 있음
    Set<int> frequencies = number_frequency.values.toSet();

    return frequencies.length == number_frequency.values.length;


  }
}
//뭐 각 리스트의 인자 값을 키로, 빈도수를 값으로 맵을 만들어서, value를 Set로 변환하여 중복 요소를 없애고 길이 차이를 확인하면 되지 않을까