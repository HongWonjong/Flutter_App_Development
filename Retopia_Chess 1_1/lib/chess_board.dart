import 'package:flutter/material.dart';
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

  void selectPiece(int index) {
    setState(() {
      // 선택된 체스말이 이미 있고, 같은 체스말을 누른 경우 선택을 취소한다.
      if (selectedPieceIndex == index) {
        selectedPieceIndex = null;
        possibleMoves = [];
      } else {
        selectedPieceIndex = index;
        possibleMoves = pieces[index].possibleMoves();

        // 같은 세력의 체스말이 있는 위치를 제거합니다.
        possibleMoves = possibleMoves.where((move) {
          for (Piece piece in pieces) {
            if (piece.position == move && piece.isWhite == pieces[index].isWhite) {
              return false;
            }
          }
          return true;
        }).toList();
      }
    });
  }




  List<Piece> pieces = [
    // 검은색 폰
    Pawn(isWhite: false, position: 8),
    Pawn(isWhite: false, position: 9),
    Pawn(isWhite: false, position: 10),
    Pawn(isWhite: false, position: 11),
    Pawn(isWhite: false, position: 12),
    Pawn(isWhite: false, position: 13),
    Pawn(isWhite: false, position: 14),
    Pawn(isWhite: false, position: 15),
    // ... 나머지 검은색 폰들
    // 하얀색 폰
    Pawn(isWhite: true, position: 48),
    Pawn(isWhite: true, position: 49),
    Pawn(isWhite: true, position: 50),
    Pawn(isWhite: true, position: 51),
    Pawn(isWhite: true, position: 52),
    Pawn(isWhite: true, position: 53),
    Pawn(isWhite: true, position: 54),
    Pawn(isWhite: true, position: 55),
    // ... 나머지 하얀색 폰들
    // 검은색 나이트
    Knight(isWhite: false, position: 1),
    Knight(isWhite: false, position: 6),

    // 하얀색 나이트
    Knight(isWhite: true, position: 57),
    Knight(isWhite: true, position: 62),

    // 검은색 비숍
    Bishop(isWhite: false, position: 2),
    Bishop(isWhite: false, position: 5),
    // 하얀색 비숍
    Bishop(isWhite: true, position: 58),
    Bishop(isWhite: true, position: 61),

    // 검은색 룩
    Rook(isWhite: false, position: 0),
    Rook(isWhite: false, position: 7),
// 하얀색 룩
    Rook(isWhite: true, position: 56),
    Rook(isWhite: true, position: 63),

    // 검은색 킹
    King(isWhite: false, position: 4),
// 하얀색 킹
    King(isWhite: true, position: 60),

    // 검은색 퀸
    Queen(isWhite: false, position: 3),
// 하얀색 퀸
    Queen(isWhite: true, position: 59),

  ];

  bool isWhite(int i, int j) => (i + j) % 2 == 0;

  void movePiece(int index, int newPosition) {
    setState(() {
      // 체스말을 이동합니다.
      pieces[index].position = newPosition;

      // 이동한 위치에 다른 체스말이 있는지 확인합니다.
      for (Piece piece in pieces) {
        if (piece.position == newPosition && piece.isWhite != pieces[index].isWhite) {
          // 이동한 위치에 다른 체스말이 있을 경우, 해당 체스말을 삭제합니다.
          piece.remove(pieces);
          break;
        }
      }
    });
  }


// 체스판 구현
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final chessBoardSize = screenHeight * 0.8;
    return Center(
      child: SizedBox(
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
                            selectPiece(k);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isWhite(i, j)
                                  ? [
                                Colors.white,
                                Colors.white.withOpacity(0.5),
                              ]
                                  : [
                                Colors.black,
                                Colors.black.withOpacity(0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              tileMode: TileMode.repeated,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5.0,
                                spreadRadius: 2.0,
                              ),
                            ],
                            border: const Border(
                              top: BorderSide(
                                width: 1.0,
                                color: Colors.white,
                              ),
                              left: BorderSide(
                                width: 1.0,
                                color: Colors.white,
                              ),
                              right: BorderSide(
                                width: 1.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (possibleMoves.contains(index))
                                Container(
                                  color: Colors.blueAccent.withOpacity(0.8),
                                ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.asset(
                                  imagePath,
                                  width: chessBoardSize / 8,
                                  height: chessBoardSize / 8,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                    return const Icon(Icons.error);
                                  },
                                ),
                              ),

                            ],
                          ),
                        ),
                      );
                    }
                  }

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: possibleMoves.contains(index)
                          ? Colors.redAccent
                          : isWhite(i, j)
                          ? Colors.white70
                          : Colors.black45,
                      gradient: LinearGradient(
                        colors: isWhite(i, j)
                            ? [
                          Colors.white,
                          Colors.white.withOpacity(0.5),
                        ]
                            : [
                          Colors.black,
                          Colors.black.withOpacity(0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        tileMode: TileMode.repeated,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                      border: const Border(
                        top: BorderSide(
                          width: 1.0,
                          color: Colors.white,
                        ),
                        left: BorderSide(
                          width: 1.0,
                          color: Colors.white,
                        ),
                        right: BorderSide(
                          width: 1.0,
                          color: Colors.black,
                        ),
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
    );
  }
}


