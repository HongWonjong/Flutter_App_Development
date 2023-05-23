import 'chess_pieces.dart';

class Pawn extends Piece {
  bool justMadeDoubleJump = false;

  Pawn({required bool isWhite, required int position, required bool hasMoved})
      : super(isWhite: isWhite, position: position, hasMoved: hasMoved);

  @override
  List<int> possibleMoves(List<Piece> pieces) {
    List<int> moves = [];
    int x = position % 8;
    int y = position ~/ 8;
    int direction = isWhite ? -1 : 1;

    // Check for double jump
    if ((isWhite && y == 6) || (!isWhite && y == 1)) {
      int doubleMovePosition = coordToIndex(x, y + direction * 2);
      if (!isOccupied(doubleMovePosition, pieces) && !isOccupied(coordToIndex(x, y + direction), pieces)) {
        moves.add(doubleMovePosition);
      }
    }

    // Check for single forward move
    int singleMovePosition = coordToIndex(x, y + direction);
    if (!isOccupied(singleMovePosition, pieces)) {
      moves.add(singleMovePosition);
    }

    // Check for diagonal capture move
    List<int> dx = [-1, 1];
    for (int i = 0; i < 2; i++) {
      int newX = x + dx[i];
      int newY = y + direction;
      int capturePosition = coordToIndex(newX, newY);
      if (newX >= 0 && newX < 8 && newY >= 0 && newY < 8) {
        if (isOccupied(capturePosition, pieces)) {
          Piece? occupyingPiece;
          for (Piece piece in pieces) {
            if (piece.position == capturePosition) {
              occupyingPiece = piece;
              break;
            }
          }
          if (occupyingPiece != null && occupyingPiece.isWhite != isWhite) { // If the piece is of different color
            moves.add(capturePosition);
          }
        }
        // Check for en passant
        if (isOccupied(coordToIndex(newX, y + direction), pieces)) {
          Piece? occupyingPiece;
          for (Piece piece in pieces) {
            if (piece.position == coordToIndex(newX, y + direction)) {
              occupyingPiece = piece;
              break;
            }
          }
          if (occupyingPiece != null && occupyingPiece is Pawn && occupyingPiece.isWhite != isWhite && occupyingPiece.justMadeDoubleJump) {
            moves.add(capturePosition);
          }
        }



      }
    }

    return moves;
  }
}