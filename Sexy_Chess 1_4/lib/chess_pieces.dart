abstract class Piece {
  final bool isWhite;
  int position;

  Piece({required this.isWhite, required this.position});

  int coordToIndex(int x, int y) {
    return x + y * 8;
  }

  void remove(List<Piece> pieces) {
    pieces.remove(this);
  }
  bool isOccupied(int index, List<Piece> pieces) {
    if (index < 0 || index >= 64) {
      return false;
    }
    for (Piece piece in pieces) {
      if (piece.position == index) {
        return true;
      }
    }
    return false;
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

  List<int> possibleMoves(List<Piece> pieces);

  bool onSameDiagonal(int otherPosition) {
    int rowDiff = (otherPosition ~/ 8 - position ~/ 8).abs();
    int colDiff = (otherPosition % 8 - position % 8).abs();

    return rowDiff == colDiff;
  }
}


class Pawn extends Piece {
  bool justMadeDoubleJump = false;

  Pawn({required bool isWhite, required int position})
      : super(isWhite: isWhite, position: position);

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


class Knight extends Piece {
  Knight({required bool isWhite, required int position})
      : super(isWhite: isWhite, position: position);

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


class Rook extends Piece {
  Rook({required bool isWhite, required int position})
      : super(isWhite: isWhite, position: position);

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

    return moves;
  }
}


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


class Queen extends Piece {
  Queen({required bool isWhite, required int position})
      : super(isWhite: isWhite, position: position);

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

