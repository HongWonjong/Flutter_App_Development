import '../pieces/chess_pieces.dart';
import 'package:flutter/material.dart';
import '../pieces/rook.dart';
import '../pieces/pawn.dart';
import '../pieces/knight.dart';
import '../pieces/bishop.dart';
import '../pieces/king.dart';
import '../pieces/queen.dart';

bool isWhiteTurn = true;




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
    hypotheticalPieces[kingIndex] = King(isWhite: isWhite, position: position, hasMoved: false);

    if (!isCheck(hypotheticalPieces, isWhite)) {
      return false;
    }
  }

  return true;
}

enum PieceType {
  Queen,
  Rook,
  Bishop,
  Knight,
}

void promotePawn(Pawn pawn, PieceType promotedTo) {
  // Find the index of the pawn in the pieces list
  int pawnIndex = pieces.indexOf(pawn);

  // Create the promoted piece based on the selected piece type
  Piece promotedPiece;
  switch (promotedTo) {
    case PieceType.Queen:
      promotedPiece = Queen(isWhite: pawn.isWhite, position: pawn.position, hasMoved: false);
      break;
    case PieceType.Rook:
      promotedPiece = Rook(isWhite: pawn.isWhite, position: pawn.position, hasMoved: false);
      break;
    case PieceType.Bishop:
      promotedPiece = Bishop(isWhite: pawn.isWhite, position: pawn.position, hasMoved: false);
      break;
    case PieceType.Knight:
      promotedPiece = Knight(isWhite: pawn.isWhite, position: pawn.position, hasMoved: false);
      break;
  }

  // Replace the pawn with the promoted piece in the pieces list
  pieces[pawnIndex] = promotedPiece;
}

Future<PieceType?> showPromotionDialog(BuildContext context) async {
  return showDialog<PieceType>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('프로모션 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, PieceType.Queen);
              },
              child: const Text('퀸'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, PieceType.Rook);
              },
              child: const Text('룩'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, PieceType.Bishop);
              },
              child: const Text('비숍'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, PieceType.Knight);
              },
              child: const Text('나이트'),
            ),
          ],
        ),
      );
    },
  );
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

void resetPieces() {
  pieces = List<Piece>.from(initialPieces);
}


List<Piece> initialPieces = [
  // Black pawns
  Pawn(isWhite: false, position: 8, hasMoved: false),
  Pawn(isWhite: false, position: 9, hasMoved: false),
  Pawn(isWhite: false, position: 10, hasMoved: false),
  Pawn(isWhite: false, position: 11, hasMoved: false),
  Pawn(isWhite: false, position: 12, hasMoved: false),
  Pawn(isWhite: false, position: 13, hasMoved: false),
  Pawn(isWhite: false, position: 14, hasMoved: false),
  Pawn(isWhite: false, position: 15, hasMoved: false),
  // White pawns
  Pawn(isWhite: true, position: 48, hasMoved: false),
  Pawn(isWhite: true, position: 49, hasMoved: false),
  Pawn(isWhite: true, position: 50, hasMoved: false),
  Pawn(isWhite: true, position: 51, hasMoved: false),
  Pawn(isWhite: true, position: 52, hasMoved: false),
  Pawn(isWhite: true, position: 53, hasMoved: false),
  Pawn(isWhite: true, position: 54, hasMoved: false),
  Pawn(isWhite: true, position: 55, hasMoved: false),
  // Black knights
  Knight(isWhite: false, position: 1, hasMoved: false),
  Knight(isWhite: false, position: 6, hasMoved: false),
  // White knights
  Knight(isWhite: true, position: 57, hasMoved: false),
  Knight(isWhite: true, position: 62, hasMoved: false),
  // Black bishops
  Bishop(isWhite: false, position: 2, hasMoved: false),
  Bishop(isWhite: false, position: 5, hasMoved: false),
  // White bishops
  Bishop(isWhite: true, position: 58, hasMoved: false),
  Bishop(isWhite: true, position: 61, hasMoved: false),
  // Black rooks
  Rook(isWhite: false, position: 0, hasMoved: false),
  Rook(isWhite: false, position: 7, hasMoved: false),
  // White rooks
  Rook(isWhite: true, position: 56, hasMoved: false),
  Rook(isWhite: true, position: 63, hasMoved: false),
  // Black king
  King(isWhite: false, position: 4, hasMoved: false),
  // White king
  King(isWhite: true, position: 60, hasMoved: false),
  // Black queen
  Queen(isWhite: false, position: 3, hasMoved: false),
  // White queen
  Queen(isWhite: true, position: 59, hasMoved: false),
];

List<Piece> pieces = [
  // Black pawns
  Pawn(isWhite: false, position: 8, hasMoved: false),
  Pawn(isWhite: false, position: 9, hasMoved: false),
  Pawn(isWhite: false, position: 10, hasMoved: false),
  Pawn(isWhite: false, position: 11, hasMoved: false),
  Pawn(isWhite: false, position: 12, hasMoved: false),
  Pawn(isWhite: false, position: 13, hasMoved: false),
  Pawn(isWhite: false, position: 14, hasMoved: false),
  Pawn(isWhite: false, position: 15, hasMoved: false),
  // White pawns
  Pawn(isWhite: true, position: 48, hasMoved: false),
  Pawn(isWhite: true, position: 49, hasMoved: false),
  Pawn(isWhite: true, position: 50, hasMoved: false),
  Pawn(isWhite: true, position: 51, hasMoved: false),
  Pawn(isWhite: true, position: 52, hasMoved: false),
  Pawn(isWhite: true, position: 53, hasMoved: false),
  Pawn(isWhite: true, position: 54, hasMoved: false),
  Pawn(isWhite: true, position: 55, hasMoved: false),
  // Black knights
  Knight(isWhite: false, position: 1, hasMoved: false),
  Knight(isWhite: false, position: 6, hasMoved: false),
  // White knights
  Knight(isWhite: true, position: 57, hasMoved: false),
  Knight(isWhite: true, position: 62, hasMoved: false),
  // Black bishops
  Bishop(isWhite: false, position: 2, hasMoved: false),
  Bishop(isWhite: false, position: 5, hasMoved: false),
  // White bishops
  Bishop(isWhite: true, position: 58, hasMoved: false),
  Bishop(isWhite: true, position: 61, hasMoved: false),
  // Black rooks
  Rook(isWhite: false, position: 0, hasMoved: false),
  Rook(isWhite: false, position: 7, hasMoved: false),
  // White rooks
  Rook(isWhite: true, position: 56, hasMoved: false),
  Rook(isWhite: true, position: 63, hasMoved: false),
  // Black king
  King(isWhite: false, position: 4, hasMoved: false),
  // White king
  King(isWhite: true, position: 60, hasMoved: false),
  // Black queen
  Queen(isWhite: false, position: 3, hasMoved: false),
  // White queen
  Queen(isWhite: true, position: 59, hasMoved: false),
];

