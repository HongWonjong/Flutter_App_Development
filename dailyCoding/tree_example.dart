// 트리 노드 클래스
class TreeNode {
  int value;
  TreeNode? left;
  TreeNode? right;

  TreeNode(this.value, [this.left, this.right]);
}

// 이진 탐색 트리 클래스
class BinarySearchTree {
  TreeNode? root;

  // 숫자 추가 (재귀적으로)
  void insert(int value) {
    root = _insertRec(root, value);
  }

  TreeNode? _insertRec(TreeNode? node, int value) {
    if (node == null) {
      return TreeNode(value); // 새 노드 생성
    }
    if (value < node.value) {
      node.left = _insertRec(node.left, value); // 왼쪽으로
    } else if (value > node.value) {
      node.right = _insertRec(node.right, value); // 오른쪽으로
    }
    return node; // 값이 이미 있으면 무시
  }

  // 숫자 찾기 (재귀적으로)
  bool search(int value) {
    return _searchRec(root, value);
  }

  bool _searchRec(TreeNode? node, int value) {
    if (node == null) return false; // 없음
    if (node.value == value) return true; // 찾음
    if (value < node.value) {
      return _searchRec(node.left, value); // 왼쪽 탐색
    }
    return _searchRec(node.right, value); // 오른쪽 탐색
  }

  // 트리 출력 (중위 순회: 왼쪽 -> 루트 -> 오른쪽)
  void printInOrder() {
    _printInOrderRec(root);
    print(''); // 줄바꿈
  }

  void _printInOrderRec(TreeNode? node) {
    if (node == null) return;
    _printInOrderRec(node.left);
    print('${node.value} '); // 공백을 문자열에 포함
    _printInOrderRec(node.right);
  }
}

// 실행 테스트
void main() {
  var bst = BinarySearchTree();

  // 숫자 추가
  bst.insert(5);
  bst.insert(3);
  bst.insert(7);
  bst.insert(1);
  bst.insert(9);

  // 트리 구조 확인 (중위 순회로 출력)
  print('트리 내용:');
  bst.printInOrder(); // 1 3 5 7 9 각 줄에 출력

  // 숫자 찾기
  print('3이 트리에 있나? ${bst.search(3)}'); // true
  print('6이 트리에 있나? ${bst.search(6)}'); // false
}
