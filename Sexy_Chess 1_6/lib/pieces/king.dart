import 'chess_pieces.dart';

class King extends Piece {
  King({required bool isWhite, required int position})
      : super(isWhite: isWhite, position: position);

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

    return moves;
  }
}