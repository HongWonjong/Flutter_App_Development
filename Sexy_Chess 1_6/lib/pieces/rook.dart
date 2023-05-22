import 'chess_pieces.dart';

class Rook extends Piece {
  bool hasMoved;

  Rook({required bool isWhite, required int position})
      : hasMoved = false,
        super(isWhite: isWhite, position: position);

  @override
  List<int> possibleMoves(List<Piece> pieces) {
    List<int> moves = [];

    List<int> dx = [-1, 0, 1, 0];
    List<int> dy = [0, 1, 0, -1];

    for (int direction = 0; direction < 4; direction++) {
      for (int step = 1; step < 8; step++) {
        int newX = position % 8 + dx[direction] * step;
        int newY = position ~/ 8 + dy[direction] * step;
        if (newX < 0 || newX >= 8 || newY < 0 || newY >= 8) {
          break;
        }

        int newIndex = coordToIndex(newX, newY);

        if (isOccupied(newIndex, pieces)) {
          if (pieces.firstWhere((piece) => piece.position == newIndex).isWhite != isWhite) {
            moves.add(newIndex);
          }
          break;
        } else {
          moves.add(newIndex);
        }
      }
    }

    // Check for castling
    if (!hasMoved) {
      moves.addAll(getCastlingMoves(pieces));
    }

    return moves;
  }

  List<int> getCastlingMoves(List<Piece> pieces) {
    List<int> castlingMoves = [];

    // King-side castling
    if (canCastleKingSide(pieces)) {
      castlingMoves.add(position + 2);
    }

    // Queen-side castling
    if (canCastleQueenSide(pieces)) {
      castlingMoves.add(position - 2);
    }

    return castlingMoves;
  }

  bool canCastleKingSide(List<Piece> pieces) {
    // Get the Rook's position
    int rookPosition = isWhite ? 63 : 7;

    // Find the Rook piece
    Rook? rook;
    try {
      rook = pieces.firstWhere((piece) => piece is Rook && piece.isWhite == isWhite && piece.position == rookPosition) as Rook?;
    } catch (e) {
      rook = null;
    }

    // If there's no Rook or it has moved, castling is not possible
    if (rook == null || rook.hasMoved) {
      return false;
    }

    // Check if there are any pieces between the King and the Rook
    int start = position + 1;
    int end = rookPosition - 1;
    for (int i = start; i <= end; i++) {
      if (isOccupied(i, pieces)) {
        return false;
      }
    }

    // Check if the King is in check in any of the positions it has to move to
    for (int i = position; i <= position + 2; i++) {
      if (isCheckPosition(i, pieces)) {
        return false;
      }
    }

    return true;
  }

  bool canCastleQueenSide(List<Piece> pieces) {
    // Get the Rook's position
    int rookPosition = isWhite ? 0 : 56;

    // Find the Rook piece
    Rook? rook;
    try {
      rook = pieces.firstWhere((piece) => piece is Rook && piece.isWhite == isWhite && piece.position == rookPosition) as Rook?;
    } catch (e) {
      rook = null;
    }

    // If there's no Rook or it has moved, castling is not possible
    if (rook == null || rook.hasMoved) {
      return false;
    }

    // Check if there are any pieces between the King and the Rook
    int start = rookPosition + 1;
    int end = position - 1;
    for (int i = start; i <= end; i++) {
      if (isOccupied(i, pieces)) {
        return false;
      }
    }

    // Check if the King is in check in any of the positions it has to move to
    for (int i = position; i >= position - 2; i--) {
      if (isCheckPosition(i, pieces)) {
        return false;
      }
    }

    return true;
  }

  bool isCheckPosition(int position, List<Piece> pieces) {
    return pieces.any((piece) => piece.isWhite != isWhite && piece.possibleMoves(pieces).contains(position));
  }
}