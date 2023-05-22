abstract class Piece {
  final bool isWhite;
  int position;
  int coordToIndex(int x, int y) {
    return x + y * 8;
  }
  void remove(List<Piece> pieces) {
    pieces.remove(this);
  }


  String getImagePath() {
    String imagePath = '';
    if (this is Pawn) {
      imagePath = isWhite
          ? 'assets/images/white_pawn.png'
          : 'assets/images/black_pawn.png';
    } else if (this is Knight) {
      imagePath = isWhite
          ? 'assets/images/white_knight.png'
          : 'assets/images/black_knight.png';
    } else if (this is Bishop) {
      imagePath = isWhite
          ? 'assets/images/white_bishop.png'
          : 'assets/images/black_bishop.png';
    } else if (this is Rook) {
      imagePath = isWhite
          ? 'assets/images/white_rook.png'
          : 'assets/images/black_rook.png';
    } else if (this is King) {
      imagePath = isWhite
          ? 'assets/images/white_king.png'
          : 'assets/images/black_king.png';
    } else if (this is Queen) {
      imagePath = isWhite
          ? 'assets/images/white_queen.png'
          : 'assets/images/black_queen.png';
    }
    return imagePath;
  }

  Piece({required this.isWhite, required this.position});

  List<int> possibleMoves();

  bool onSameDiagonal(int otherPosition) {
    int rowDiff = (otherPosition ~/ 8 - position ~/ 8).abs();
    int colDiff = (otherPosition % 8 - position % 8).abs();

    return rowDiff == colDiff;
  }
}

class Pawn extends Piece {
  Pawn({required bool isWhite, required int position})
      : super(isWhite: isWhite, position: position);

  @override
  List<int> possibleMoves() {
    List<int> moves = [];
    int x = position % 8;
    int y = position ~/ 8;

    int direction = isWhite ? -1 : 1;

    if (isWhite && y == 6 || !isWhite && y == 1) {
      moves.add(coordToIndex(x, y + direction * 2));
    }

    moves.add(coordToIndex(x, y + direction));

    return moves;
  }

}

class Knight extends Piece {
  Knight({required bool isWhite, required int position})
      : super(isWhite: isWhite, position: position);

  @override
  List<int> possibleMoves() {
    List<int> moves = [];
    int x = position % 8;
    int y = position ~/ 8;

    List<int> dx = [1, 2, 2, 1, -1, -2, -2, -1];
    List<int> dy = [2, 1, -1, -2, -2, -1, 1, 2];

    for (int i = 0; i < 8; i++) {
      int newX = x + dx[i];
      int newY = y + dy[i];
      if (newX >= 0 && newX < 8 && newY >= 0 && newY < 8) {
        moves.add(coordToIndex(newX, newY));
      }
    }

    return moves;
  }

}

class Bishop extends Piece {
  Bishop({required bool isWhite, required int position})
      : super(isWhite: isWhite, position: position);

  @override
  List<int> possibleMoves() {
    List<int> moves = [];

    for (int i = 0; i < 64; i++) {
      if (i != position && onSameDiagonal(i)) {
        moves.add(i);
      }
    }

    return moves;
  }
}

class Rook extends Piece {
  Rook({required bool isWhite, required int position})
      : super(isWhite: isWhite, position: position);

  @override
  List<int> possibleMoves() {
    List<int> moves = [];

    for (int i = 0; i < 8; i++) {
      int verticalMove = i * 8 + position % 8;
      int horizontalMove = position ~/ 8 * 8 + i;

      if (verticalMove != position) {
        moves.add(verticalMove);
      }

      if (horizontalMove != position) {
        moves.add(horizontalMove);
      }
    }

    return moves;
  }
}

class King extends Piece {
  King({required bool isWhite, required int position})
      : super(isWhite: isWhite, position: position);

  @override
  List<int> possibleMoves() {
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

class Queen extends Piece {
  Queen({required bool isWhite, required int position})
      : super(isWhite: isWhite, position: position);

  @override
  List<int> possibleMoves() {
    List<int> moves = [];

    for (int i = 0; i < 64; i++) {
      if (i != position && (onSameDiagonal(i) || onSameRow(i) || onSameColumn(i))) {
        moves.add(i);
      }
    }

    return moves;
  }

  bool onSameRow(int otherPosition) {
    return position ~/ 8 == otherPosition ~/ 8;
  }

  bool onSameColumn(int otherPosition) {
    return position % 8 == otherPosition % 8;
  }
}

