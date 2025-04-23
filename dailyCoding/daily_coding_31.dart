/**
 * Definition for a binary tree node.
 * class TreeNode {
 *   int val;
 *   TreeNode? left;
 *   TreeNode? right;
 *   TreeNode([this.val = 0, this.left, this.right]);
 * }
 */
class Solution {
  List<int> root1List = [];
  List<int> root2List = [];

  // 리프 노드를 수집하는 헬퍼 함수
  void collectLeaves(TreeNode? node, List<int> leafList) {
    if (node == null) return;
    // 리프 노드인 경우 (left와 right가 모두 null)
    if (node.left == null && node.right == null) {
      leafList.add(node.val);
      return;
    }
    // 좌우 서브트리를 재귀적으로 호출
    collectLeaves(node.left, leafList);
    collectLeaves(node.right, leafList);
  }

  bool leafSimilar(TreeNode? root1, TreeNode? root2) {

    collectLeaves(root1, root1List);
    collectLeaves(root2, root2List);

    // 두 리스트 비교
    if (root1List.length != root2List.length) return false;
    for (int i = 0; i < root1List.length; i++) {
      if (root1List[i] != root2List[i]) return false;
    }
    return true;
  }
}