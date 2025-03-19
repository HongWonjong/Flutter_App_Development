class Solution {
  int lengthOfLastWord(String s) {
    List<String> splitted_word = s.trim().split(" ");

    return splitted_word[splitted_word.length-1].length;
  }
}