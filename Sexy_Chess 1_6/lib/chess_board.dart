import 'package:flutter/material.dart';
import 'dart:async';
import 'pieces/chess_pieces.dart';
import 'chess_board_logic.dart';
import'package:firebase_auth/firebase_auth.dart';
import 'waiting_screen.dart';
import 'pieces/pawn.dart';

class ChessBoard extends StatefulWidget {
  final User? user;
  const ChessBoard({Key? key, this.user}) : super(key: key);

  @override
  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  int? selectedPieceIndex;
  List<int> possibleMoves = [];
  Duration elapsedTime = Duration.zero;
  Timer? moveTimer;
  int turnCounter = 1;
  User? user;

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
      ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove the existing SnackBar if it exists
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "자신의 턴이 아닙니다.",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void movePiece(int index, int newPosition) {
    setState(() {
      isWhiteTurn = !isWhiteTurn;
      turnCounter += 1;
      pieces[index].position = newPosition;

      handleCapture(index, newPosition);
      try {
        String winner = checkForVictory(pieces);
        showVictoryDialog(context, winner);
      } catch (e) {
        return;
      }
      handleEnPassantCapture(index, newPosition);
      resetDoubleJumpFlags();
      setDoubleJumpFlag(index, newPosition);
      handleMoveTimer();
    });
  }

  void handleEnPassantCapture(int index, int newPosition) {
    if (index < 0 || index >= pieces.length) {
      return;
    }

    if (pieces[index] is Pawn) {
      Pawn movingPawn = pieces[index] as Pawn;

      if (movingPawn.justMadeDoubleJump) {
        int capturePosition = isWhiteTurn ? newPosition - 8 : newPosition + 8;
        int capturedPieceIndex = pieces.indexWhere(
              (piece) =>
          piece.position == capturePosition &&
              piece is Pawn &&
              piece.isWhite != isWhiteTurn,
        );

        if (capturedPieceIndex != -1) {
          pieces.removeAt(capturedPieceIndex);
        }
      }
    }
  }

  void handleCapture(int index, int newPosition) {
    int capturedPieceIndex = pieces.indexWhere(
          (piece) =>
      piece.position == newPosition &&
          piece.isWhite != pieces[index].isWhite,
    );
    if (capturedPieceIndex != -1) {
      pieces.removeAt(capturedPieceIndex);
      if (capturedPieceIndex < index) {
        index--;
      }
    }
  }

  void resetDoubleJumpFlags() {
    for (Piece piece in pieces) {
      if (piece is Pawn) {
        piece.justMadeDoubleJump = false;
      }
    }
  }

  void setDoubleJumpFlag(int index, int newPosition) {
    if (index < 0 || index >= pieces.length) {
      return;
    }

    if (pieces[index] is Pawn &&
        (newPosition - pieces[index].position).abs() == 16) {
      (pieces[index] as Pawn).justMadeDoubleJump = true;
    }
  }

  void showVictoryDialog(BuildContext context, String winner) {
    String winnerMessage;
    if (winner == "White") {
      winnerMessage = "흰색 플레이어가 승리하였습니다! 턴 수: $turnCounter";
    } else if (winner == "Black") {
      winnerMessage = "검은색 플레이어가 승리하였습니다! 턴 수: $turnCounter";
    } else {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게임 종료'),
          content: Text(winnerMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WaitingScreen(user: widget.user),
                  ),
                );

                // 게임 초기화
                setState(() {
                  selectedPieceIndex = null;
                  possibleMoves = [];
                  elapsedTime = Duration.zero;
                  moveTimer?.cancel();
                  isWhiteTurn = true;
                  turnCounter = 1;
                  resetPieces();
                });
              },
            ),
          ],
        );
      },
    );
  }


  void handleMoveTimer() {
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
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final chessBoardSize = screenHeight * 0.99;

    Widget googleIdText = const Text(
      '누구냐 넌',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );

    if (widget.user != null && widget.user!.displayName != null) {
      String displayName = widget.user!.displayName!;
      if (displayName.length > 15) {
        displayName = '${displayName.substring(0, 12)}...';
      }
      googleIdText = Text(
        'Google ID: $displayName',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: chessBoardSize,
            height: chessBoardSize,
            child: Padding(
              padding: EdgeInsets.only(top: chessBoardSize * 0.07),
              child: CustomScrollView(
                slivers: [
                  SliverGrid(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      childAspectRatio: 1.08,
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
                                if (possibleMoves.contains(index) &&
                                    selectedPieceIndex != null) {
                                  movePiece(selectedPieceIndex!, index);
                                  setState(() {
                                    selectedPieceIndex = null;
                                    possibleMoves = [];
                                  });
                                } else {
                                  selectPiece(
                                      k); // if not a possible move, then select the piece
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isWhite(i, j)
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.brown.withOpacity(0.8),
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
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace,) {
                                          return const Icon(Icons.error);
                                        },
                                      ),
                                    ),
                                    if (possibleMoves.contains(index))
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              12.0),
                                          color: selectedPieceIndex != null &&
                                              pieces.any(
                                                    (piece) =>
                                                piece.position ==
                                                    index &&
                                                    piece.isWhite !=
                                                        pieces[selectedPieceIndex!]
                                                            .isWhite,
                                              )
                                              ? Colors.red.withOpacity(0.5)
                                              : Colors.blueAccent.withOpacity(
                                              0.5),
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
                            if (possibleMoves.contains(index) &&
                                selectedPieceIndex != null) {
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
                                : Colors.brown.withOpacity(0.8)),
                          ),
                        );
                      },
                      childCount: 64,
                    ),
                  ),
                ],
              ),
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
                  isCheckmate(pieces, isWhiteTurn)
                      ? 'Checkmate!'
                      : (isCheck(pieces, isWhiteTurn) ? 'Check!' : (isWhiteTurn
                      ? 'White\'s turn'
                      : 'Black\'s turn')),
                  style: TextStyle(
                    color: isWhiteTurn ? Colors.black : Colors.white,
                    fontSize: 30,
                    fontWeight: isCheckmate(pieces, isWhiteTurn)
                        ? FontWeight.bold
                        : FontWeight.normal,
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
              const SizedBox(height: 30),
              Text(
                (29 - elapsedTime.inSeconds <= 0.5)
                    ? '시간 초과.'
                    : 'Time remaining:',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                (29 - elapsedTime.inSeconds <= 0)
                    ? '00.00'
                    : '${(29 - elapsedTime.inSeconds).toString().padLeft(2, '0')}.${(999 - elapsedTime.inMilliseconds % 1000).toString().padLeft(3, '0').substring(0, 2)} 초',
                style: TextStyle(
                  fontSize: 50,
                  color: elapsedTime.inSeconds <= 10
                      ? Colors.black
                      : elapsedTime.inSeconds <= 20
                      ? Colors.yellow[700]
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.user != null) googleIdText,
            ],
          ),
        ],
      ),
    );
  }
}



