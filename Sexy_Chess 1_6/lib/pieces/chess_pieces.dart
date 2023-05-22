import 'rook.dart';
import 'pawn.dart';
import 'knight.dart';
import 'bishop.dart';
import 'king.dart';
import 'queen.dart';

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


