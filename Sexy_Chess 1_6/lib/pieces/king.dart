import 'chess_pieces.dart';
import 'rook.dart';
// ignore: depend_on_referenced_packages
import "package:collection/collection.dart";

class King extends Piece {
  King({required bool isWhite, required int position, required bool hasMoved})
      : super(isWhite: isWhite, position: position, hasMoved: hasMoved);

  @override
  List<int> possibleMoves(List<Piece> pieces) {
    List<int> moves = [];
    List<int> moveOffsets = [-9, -8, -7, -1, 1, 7, 8, 9];

    for (int offset in moveOffsets) {
      int newPosition = position + offset;

      if (newPosition >= 0 && newPosition < 64) {
        int rowDiff = (newPosition ~/ 8 - position ~/ 8).abs();
        int colDiff = (newPosition % 8 - position % 8).abs();

        if (rowDiff <= 1 && colDiff <= 1) {
          moves.add(newPosition);
        }
      }
    }

    // 캐슬링을 추가합니다.
    if (!hasMoved) {
      // 오른쪽 캐슬링
      if (canCastle(pieces, position + 2)) {
        moves.add(position + 2);
      }
      // 왼쪽 캐슬링
      if (canCastle(pieces, position - 2)) {
        moves.add(position - 2);
      }
    }

    return moves;
  }

  bool canCastle(List<Piece> pieces, int endPosition) {
    // 킹의 현재 위치로부터 목표 위치까지의 모든 위치를 계산합니다.
    int step = (endPosition > position) ? 1 : -1;
    for (int pos = position + step; pos != endPosition; pos += step) {
      // 경로상에 다른 체스말이 있는지 확인합니다.
      if (pieces.any((piece) => piece.position == pos)) {
        return false;
      }
      // 경로상에 킹이 공격당할 수 있는 위치가 있는지 확인합니다.
      if (isPositionUnderAttack(pieces, pos)) {
        return false;
      }
    }

    // 캐슬링이 가능한지 최종적으로 확인합니다.
    int rookPosition = (endPosition > position) ? position + 3 : position - 4;
    Piece? rook = pieces.firstWhereOrNull((piece) => piece is Rook && piece.position == rookPosition);
    if (rook == null || rook.hasMoved) {
      return false;
    }

    return true;
  }

  bool isPositionUnderAttack(List<Piece> pieces, int position) {
    // 주어진 위치가 공격 당할 수 있는지 확인합니다.
    // 임시적으로 킹의 위치를 업데이트하여 공격당할 수 있는지 확인합니다.
    int originalPosition = this.position;
    this.position = position;
    for (Piece piece in pieces.where((piece) => piece.isWhite != this.isWhite)) {
      if (piece.possibleMoves(pieces).contains(position)) {
        // 킹의 위치를 원래대로 돌려놓습니다.
        this.position = originalPosition;
        return true;
      }
    }
    // 킹의 위치를 원래대로 돌려놓습니다.
    this.position = originalPosition;
    return false;
  }


  void performCastling(List<Piece> pieces, int endPosition) {
    // 룩이 캐슬링에 따라 이동해야 할 위치를 계산합니다.
    int rookNewPosition = (endPosition > position) ? position + 1 : position - 1;
    int rookOriginalPosition = (endPosition > position) ? position + 3 : position - 4;

    // 캐슬링에 참여하는 룩을 찾아서 위치를 업데이트합니다.
    Piece? rook = pieces.firstWhereOrNull((piece) => piece is Rook && piece.position == rookOriginalPosition);
    if (rook != null) {
      rook.position = rookNewPosition;
    }
  }
}



