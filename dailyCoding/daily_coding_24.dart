class Solution {

  Map<String, int> ransomMap = {};
  Map<String, int> magazineMap = {};
  bool canConstruct(String ransomNote, String magazine) {
    for (int rune in ransomNote.runes) {
      String char = String.fromCharCode(rune);
      ransomMap[char] = (ransomMap[char] ?? 0) + 1;
    }

    for (int rune in magazine.runes) {
      String char = String.fromCharCode(rune);
      magazineMap[char] = (magazineMap[char] ?? 0) + 1;
    }
    if(ransomMap.isEmpty){
      return true;
    }

    for(String key in ransomMap.keys) {
      if(!magazineMap.containsKey(key) || magazineMap[key]! < ransomMap[key]!){
        return false;
      }
    }
    return true;

  }
}

