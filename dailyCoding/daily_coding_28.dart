/**
 * Definition for a binary tree node.
 * class TreeNode {
 *   int val;
 *   TreeNode? left;
 *   TreeNode? right;
 *   TreeNode([this.val = 0, this.left, this.right]);
 * }
 */

// 함수의 진정한 리턴 조건은 맨 앞에 나와서 무엇을 찾아야 할지 지정하고 있고,
// 그 조건을 만족하지 못하는 중간과정은 그 다음에 재귀적으로 실행된다. 여기서 val과 root.val의 크기를 비교함으로써 노드의 분기를 만든다. 현재 root의 val가 val보다 작다면 오른쪽으로, 크다면 왼쪽으로 이동하면 될 것이다.
//따라서 반드시 그런 것은 아니지만, return 코드는 3개 정도가 될 것이라고 예상해볼 수 있다. 재귀함수는 return을 여러 번 활용하여 자신의 핵심 기능인 재귀를 구현하므로..
//주어진 조건은 값을 가진 노드가 없다면 null을 반환하고, 아니라면 주어진 값을 가진 노드를 루트로 하는 서브트리를 반환하는 것이었다.
class Solution {
  TreeNode? searchBST(TreeNode? root, int val) {
    if(root ==null || root.val ==val) {
      return root;
    }

    if(val < root.val) {
      return searchBST(root.left, val);
    } else {
      return searchBST(root.right, val);
    }
  }
}