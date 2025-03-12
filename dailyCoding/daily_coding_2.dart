// 로마자 변환 클래스를 만들어보자. 완성

class Solution {
  List<String> splitted_roman = [];
  List<int> splitted_number = [];
  int total_number = 0;
  int temp_number = 0; // 이전 로마자의 정수를 저장하는 변수

  int romanToInt(String s) {
    splitted_roman = s.split("");
    for (int i = 0; i < splitted_roman.length; i++) {
      switch (splitted_roman[i]) {
        case "I":
          splitted_number.add(1);
          break;
        case "V":
          splitted_number.add(5);
          break;
        case "X":
          splitted_number.add(10);
          break;
        case "L":
          splitted_number.add(50);
          break;
        case "C":
          splitted_number.add(100);
          break;
        case "D":
          splitted_number.add(500);
          break;
        case "M":
          splitted_number.add(1000);
          break;
      }
    }
    for (int i = 0; i < splitted_number.length; i++) {
      if (i == splitted_number.length - 1) {
        total_number += splitted_number[i];
        break;
      }
      if (splitted_number[i] > splitted_number[i + 1]) {
        total_number += splitted_number[i] + temp_number;
        temp_number = 0;
      } else if (splitted_number[i] < splitted_number[i + 1]) {
        total_number +=
            (splitted_number[i + 1] - splitted_number[i] - temp_number);
        temp_number = 0;
        i++;
      } else if (splitted_number[i] == splitted_number[i + 1]) {
        temp_number += splitted_number[i];
      }
    }
    total_number += temp_number;
    return total_number;
  }
}
