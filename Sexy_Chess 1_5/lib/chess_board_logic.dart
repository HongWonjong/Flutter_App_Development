import 'chess_pieces.dart';

bool isCheck(List<Piece> pieces, bool isWhite) {
  // Find the King
  Piece? king;
  try {
    king = pieces.firstWhere(
          (piece) => piece is King && piece.isWhite == isWhite,
    );
  } catch (e) {
    king = null;
  }





  // ignore: unnecessary_null_comparison
  if (king == null) {
    return false; // King이 없으면 체크 상태가 아님
  }

  // Calculate all moves for the opponent
  List<int> allOpponentMoves = [];
  pieces.where((piece) => piece.isWhite != isWhite).forEach((piece) {
    allOpponentMoves.addAll(piece.possibleMoves(pieces));
  });

  // Check if the King's position is in the list of opponent moves
  return allOpponentMoves.contains(king.position);
}



bool isCheckmate(List<Piece> pieces, bool isWhite) {
  if (!isCheck(pieces, isWhite)) {
    return false;
  }

  // Find the King
  Piece king = pieces.firstWhere((piece) => piece is King && piece.isWhite == isWhite);

  // Calculate all moves for the King
  List<int> allKingMoves = king.possibleMoves(pieces);

  // Check if the King can move to a safe position
  for (int position in allKingMoves) {
    List<Piece> hypotheticalPieces = List<Piece>.from(pieces);
    int kingIndex = hypotheticalPieces.indexWhere((piece) => piece is King && piece.isWhite == isWhite);

    // Make a new King piece with the hypothetical position
    hypotheticalPieces[kingIndex] = King(isWhite: isWhite, position: position);

    if (!isCheck(hypotheticalPieces, isWhite)) {
      return false;
    }
  }

  return true;
}


String checkForVictory(List<Piece> pieces) {
  bool whiteKingPresent = false;
  bool blackKingPresent = false;
  for (Piece piece in pieces) {
    if (piece is King) {
      if (piece.isWhite) {
        whiteKingPresent = true;
      } else {
        blackKingPresent = true;
      }
    }
    if (whiteKingPresent && blackKingPresent) {
      break;
    }
  }

  if (!whiteKingPresent) {
    return "Black";
  }
  if (!blackKingPresent) {
    return "White";
  }

  if (isCheckmate(pieces, true)) {
    return "Black";
  }

  if (isCheckmate(pieces, false)) {
    return "White";
  }

  return "None";
}



bool isWhite(int i, int j) => (i + j) % 2 == 0;


List<Piece> pieces = [
  // Black pawns
  Pawn(isWhite: false, position: 8),
  Pawn(isWhite: false, position: 9),
  Pawn(isWhite: false, position: 10),
  Pawn(isWhite: false, position: 11),
  Pawn(isWhite: false, position: 12),
  Pawn(isWhite: false, position: 13),
  Pawn(isWhite: false, position: 14),
  Pawn(isWhite: false, position: 15),
  // White pawns
  Pawn(isWhite: true, position: 48),
  Pawn(isWhite: true, position: 49),
  Pawn(isWhite: true, position: 50),
  Pawn(isWhite: true, position: 51),
  Pawn(isWhite: true, position: 52),
  Pawn(isWhite: true, position: 53),
  Pawn(isWhite: true, position: 54),
  Pawn(isWhite: true, position: 55),
  // Black knights
  Knight(isWhite: false, position: 1),
  Knight(isWhite: false, position: 6),
  // White knights
  Knight(isWhite: true, position: 57),
  Knight(isWhite: true, position: 62),
  // Black bishops
  Bishop(isWhite: false, position: 2),
  Bishop(isWhite: false, position: 5),
  // White bishops
  Bishop(isWhite: true, position: 58),
  Bishop(isWhite: true, position: 61),
  // Black rooks
  Rook(isWhite: false, position: 0),
  Rook(isWhite: false, position: 7),
  // White rooks
  Rook(isWhite: true, position: 56),
  Rook(isWhite: true, position: 63),
  // Black king
  King(isWhite: false, position: 4),
  // White king
  King(isWhite: true, position: 60),
  // Black queen
  Queen(isWhite: false, position: 3),
  // White queen
  Queen(isWhite: true, position: 59),
];
