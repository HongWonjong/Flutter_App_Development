import 'chess_pieces.dart';

class Knight extends Piece {
  Knight({required bool isWhite, required int position, required bool hasMoved})
      : super(isWhite: isWhite, position: position, hasMoved: hasMoved);

  @override
  List<int> possibleMoves(List<Piece> pieces) {
    List<int> moves = [];
    int x = position % 8;
    int y = position ~/ 8;

    // Define knight's move offsets
    List<int> dx = [1, 2, 2, 1, -1, -2, -2, -1];
    List<int> dy = [2, 1, -1, -2, -2, -1, 1, 2];

    for (int i = 0; i < 8; i++) {
      int newX = x + dx[i];
      int newY = y + dy[i];
      int newPosition = coordToIndex(newX, newY);
      if (newX >= 0 && newX < 8 && newY >= 0 && newY < 8) {
        if (!isOccupied(newPosition, pieces) ||
            (isOccupied(newPosition, pieces) && pieces.firstWhere((piece) => piece.position == newPosition).isWhite != isWhite)) {
          moves.add(newPosition);
        }
      }
    }

    return moves;
  }
}