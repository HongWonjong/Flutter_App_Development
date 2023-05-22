import 'chess_pieces.dart';

class Bishop extends Piece {
  Bishop({required bool isWhite, required int position})
      : super(isWhite: isWhite, position: position);

  @override
  List<int> possibleMoves(List<Piece> pieces) {
    List<int> moves = [];

    List<int> dx = [-1, 1, -1, 1];
    List<int> dy = [-1, -1, 1, 1];

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

    return moves;
  }
}