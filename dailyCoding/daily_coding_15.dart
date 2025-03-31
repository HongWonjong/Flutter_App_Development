class Solution {
  bool isIsomorphic(String s, String t) {
    if (s.length != t.length) return false;

    Map<String, String> mapST = {};
    Map<String, String> mapTS = {};

    for (int i = 0; i < s.length; i++) { // [egg, add]
      String charS = s[i];
      String charT = t[i];

      if (mapST.containsKey(charS)) {
        if (mapST[charS] != charT) return false;
      } else {
        mapST[charS] = charT;
      }

      if (mapTS.containsKey(charT)) {
        if (mapTS[charT] != charS) return false;
      } else {
        mapTS[charT] = charS;
      }
    }

    return true;
  }
}