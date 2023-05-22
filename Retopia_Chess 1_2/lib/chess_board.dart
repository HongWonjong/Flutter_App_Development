import 'package:flutter/material.dart';
import 'dart:async';
import 'chess_pieces.dart';

class ChessBoard extends StatefulWidget {
  const ChessBoard({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  int? selectedPieceIndex;
  List<int> possibleMoves = [];
  Duration elapsedTime = Duration.zero;
  Timer? moveTimer;
  bool isWhiteTurn = true;
  int turnCounter = 1;  // Add this line


  void selectPiece(int index) {
    if (pieces[index].isWhite == isWhiteTurn) {
      setState(() {
        if (selectedPieceIndex == index) {
          selectedPieceIndex = null;
          possibleMoves = [];
        } else {
          selectedPieceIndex = index;
          possibleMoves = pieces[index].possibleMoves(pieces);

          possibleMoves = possibleMoves.where((move) {
            bool canMove = true; // Initialize as true
            for (Piece piece in pieces) {
              if (piece.position == move) {
                if (piece.isWhite == pieces[index].isWhite) {
                  canMove = false; // Same team, can't move
                } else {
                  canMove = true; // Different team, can attack
                }
                break;
              }
            }
            return canMove;
          }).toList();
        }
      });
    } else {
      ScaffoldMessenger.of(context)
          .removeCurrentSnackBar(); // Remove the existing SnackBar if it exists
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("자신의 턴이 아닙니다.",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }





  void movePiece(int index, int newPosition) {
    setState(() {
      // Check if the piece being moved is capturing an opponent's piece
      bool capturedPiece = false;
      int capturedPieceIndex = -1;
      isWhiteTurn = !isWhiteTurn;
      turnCounter += 1;
      for (int i = 0; i < pieces.length; i++) {
        if (pieces[i].position == newPosition && pieces[i].isWhite != pieces[index].isWhite) {
          capturedPiece = true;
          capturedPieceIndex = i;
          break;
        }
      }

      pieces[index].position = newPosition;

      // Remove the captured piece from the board
      if (capturedPiece) {
        pieces.removeAt(capturedPieceIndex);
      }

      // Check for victory condition
      bool whiteKingPresent = false;
      bool blackKingPresent = false;
      for (Piece piece in pieces) {
        if (piece is King) {  // if the piece is King
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

      if (!whiteKingPresent || !blackKingPresent) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('게임 종료'),
              content: Text(!whiteKingPresent
                  ? "검은색 플레이어가 승리하였습니다!"
                  : "흰색 플레이어가 승리하였습니다!"),
              actions: <Widget>[
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }

      // Cancel the existing timer
      moveTimer?.cancel();

      // Start a new timer when the piece moves
      elapsedTime = Duration.zero;
      moveTimer = Timer.periodic(const Duration(milliseconds: 1), (Timer timer) {
        setState(() {
          if (elapsedTime.inSeconds < 30) {
            elapsedTime += const Duration(milliseconds: 1);
          } else {
            // Cancel the timer when 30 seconds have passed
            timer.cancel();
          }
        });
      });
    });
  }




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

  bool isWhite(int i, int j) => (i + j) % 2 == 0;


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final chessBoardSize = screenHeight * 0.8;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: chessBoardSize,
            height: chessBoardSize,
            child: CustomScrollView(
              slivers: [
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 1.0,
                    crossAxisSpacing: 1.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      int i = (index / 8).floor();
                      int j = index % 8;

                      for (int k = 0; k < pieces.length; k++) {
                        if (index == pieces[k].position) {
                          String imagePath = pieces[k].getImagePath();

                          return GestureDetector(
                            onTap: () {
                              if (possibleMoves.contains(index) && selectedPieceIndex != null) {
                                movePiece(selectedPieceIndex!, index);
                                setState(() {
                                  selectedPieceIndex = null;
                                  possibleMoves = [];
                                });
                              } else {
                                selectPiece(k); // if not a possible move, then select the piece
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isWhite(i, j) ? Colors.white.withOpacity(0.8) : Colors.brown.withOpacity(0.8),
                                border: Border.all(
                                  width: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Image.asset(
                                      imagePath,
                                      width: chessBoardSize / 8,
                                      height: chessBoardSize / 8,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                      errorBuilder: (BuildContext context, Object exception,
                                          StackTrace? stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    ),
                                  ),
                                  if (possibleMoves.contains(index))
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12.0),
                                        color: selectedPieceIndex != null && pieces.any((piece) => piece.position == index && piece.isWhite != pieces[selectedPieceIndex!].isWhite)
                                            ? Colors.red.withOpacity(0.5)
                                            : Colors.blueAccent.withOpacity(0.5),
                                      ),
                                      width: chessBoardSize / 8,
                                      height: chessBoardSize / 8,
                                    ),
                                ],
                              ),

                            ),
                          );
                        }
                      }

                      // If not a piece, then just an empty square
                      return GestureDetector(
                        onTap: () {
                          if (possibleMoves.contains(index) && selectedPieceIndex != null) {
                            movePiece(selectedPieceIndex!, index);
                            setState(() {
                              selectedPieceIndex = null;
                              possibleMoves = [];
                            });
                          }
                        },
                        child: Container(
                          color: possibleMoves.contains(index)
                              ? Colors.blueAccent.withOpacity(0.7)
                              : (isWhite(i, j)
                              ? Colors.white.withOpacity(0.8)
                              : Colors.brown.withOpacity(0.8)
                          ),
                        ),
                      );
                    },
                    childCount: 64,
                  ),

                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: isWhiteTurn ? Colors.white : Colors.black,
                  border: Border.all(
                    color: isWhiteTurn ? Colors.black : Colors.white,
                  ),
                ),
                child: Text(
                  isWhiteTurn ? 'White\'s turn' : 'Black\'s turn',
                  style: TextStyle(
                    color: isWhiteTurn ? Colors.black : Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Turn: $turnCounter',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 140),
              Text(
                (29 - elapsedTime.inSeconds <= 0.5) ? '시간 초과.' : 'Time remaining:',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                (29 - elapsedTime.inSeconds <= 0) ? '00.00' : '${(29 - elapsedTime.inSeconds).toString().padLeft(2, '0')}.${(999 - elapsedTime.inMilliseconds % 1000).toString().padLeft(3, '0').substring(0, 2)} 초',
                style: TextStyle(
                  fontSize: 50,
                  color: elapsedTime.inSeconds <= 10 ? Colors.black : elapsedTime.inSeconds <= 20 ? Colors.yellow[700] : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}


