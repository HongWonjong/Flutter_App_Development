import 'chess_pieces.dart';

class Queen extends Piece {
  Queen({required bool isWhite, required int position, required bool hasMoved})
      : super(isWhite: isWhite, position: position, hasMoved: hasMoved);

  @override
  List<int> possibleMoves(List<Piece> pieces) {
    List<int> moves = [];

    List<int> dx = [-1, 0, 1, 0, -1, 1, -1, 1];
    List<int> dy = [0, 1, 0, -1, -1, -1, 1, 1];

    for (int direction = 0; direction < 8; direction++) {
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

    return moves;
  }
}