/**
 * Definition for singly-linked list.
 * class ListNode {
 *   int val;
 *   ListNode? next;
 *   ListNode([this.val = 0, this.next]);
 * }
 */
class Solution {
  ListNode? reverseList(ListNode? head) {
    ListNode? prev = null; // 모든 노드의 연결을 반대로 연결하면서 끝까지 간 다음 끝을 리턴하면 순서가 반대가 된다.
    ListNode? current = head; //[1, 2, 3, 4, 5] 중 1에 해당

    while (current != null) {
      ListNode? nextTemp = current.next; // 다음 노드를 변경하기 전 다음에 갈 노드로 미리 저장
      current.next = prev;              //  노드를 이전 노드로 변경(처음엔 null)
      prev = current;                    // 이전 노드에 현재 노드를 대입
      current = nextTemp;                // 현재 노드를 다음 노드로 변경
    }//즉 원래 노드에서 1을 제외한 부분을 하나 하나 삭제해가며, 그 대신 1에 연결될 새로운 꼬리가 생겨난다고 볼 수 있다.

    return prev; //전부 끝나면 원래 노드에서 5에 해당했던 부분부터 리턴하면 5, 4, 3, 2, 1
  }
}