class Solution {
  int maxDepth(TreeNode? root) {
    // 이 if문을 통해 모든 재귀함수는 마지막에 0을 리턴하고, 앞의 재귀함수는 그 결과 1을 받는다.
    // 가장 마지막의 재귀함수들은 1을 가지고 앞으로 돌아오고, 이게 계속 쌓이면서 처음의 재귀함수는
    //가장 긴 깊이를 보고받고, 자신의 깊이를 더하여 리턴한다.
    if (root == null) {
      return 0;
    }

    int leftDepth = maxDepth(root.left);
    int rightDepth = maxDepth(root.right); // 이 둘의 값은 자신 아래의 모든 깊이를 구한 후에야 할당된다.
    return 1 + (leftDepth > rightDepth ? leftDepth : rightDepth);
  }
}