class Solution {
  String reverseVowels(String s) {
    // 모음인지 여부를 결정하기 위한 대소문자
    List<String> aeiou = ["a", "e", "i", "o", "u", "A", "E", "I", "O", "U"];

    // 모음의 인덱스와 값을 저장하기 위한 맵

    Map<int, String> map = {};
    for(int i = 0; i < s.length; i ++) {
      if(aeiou.contains(s[i])) {
        map[i] = s[i]; // 정방향 저장
      }
    }
    // 모음 값을 역순 리스트로 가져오기
    List<String> vowels = map.values.toList().reversed.toList();

    // 문자열을 리스트로 변환해 수정, 인덱스 일치 여부는 맵에서 찾고 실제 할당 값은 리스트 이용
    List<String> chars = s.split('');
    int vowelIndex = 0;
    for (int i = 0; i < s.length; i++) {
      if (map.containsKey(i)) {
        chars[i] = vowels[vowelIndex];
        vowelIndex++;
      }
    }

    return chars.join(''); // 리스트를 다시 문자열로 결합 후 리턴
  }
}
/// 생각해보기..
/// 일단 주어진 문자열에서 aeiou 모음에 해당하는 부분만 찾아서 인덱스와 함께 맵에 저장한다.
/// 그 다음 맵의 값을 뒤집어서 다시 저장하는 법을 찾아서 실행한 뒤, 맵의 키-값을 이용하여
/// 원래의 문자열에 인덱스에 맞게 반전된 모음들을 저장한다.

/// 이러면 일단 될 것 같구만.
/// 그러면 애초에 저장할 때 키에 인덱스를 저장하고, 값으로는 반복문을 반대로 돌려서 저장하면 되지 않을까?