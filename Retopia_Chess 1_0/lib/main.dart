import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class Piece {
  final bool isWhite;
  int position;

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
    int moveDirection = isWhite ? -8 : 8;
    int newPosition = position + moveDirection;
    return newPosition >= 0 && newPosition < 64 ? [newPosition] : [];
  }
}

class Knight extends Piece {
  Knight({required bool isWhite, required int position})
      : super(isWhite: isWhite, position: position);

  @override
  List<int> possibleMoves() {
    List<int> moves = [];
    List<int> moveOffsets = [-17, -15, -10, -6, 6, 10, 15, 17];

    for (int offset in moveOffsets) {
      int newPosition = position + offset;

      if (newPosition >= 0 && newPosition < 64) {
        int rowDiff = (newPosition ~/ 8 - position ~/ 8).abs();
        int colDiff = (newPosition % 8 - position % 8).abs();

        if ((rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2)) {
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



class ChessBoard extends StatefulWidget {
  const ChessBoard({Key? key}) : super(key: key);

  @override
  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
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
    Knight(isWhite: true, position: 57), Knight(isWhite: true, position: 62),

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

// 체스말을 이동시키는 함수
  void movePiece(int index, int newPosition) {
    setState(() {
      pieces[index].position = newPosition;
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
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                int i = (index / 8).floor();
                int j = index % 8;

                for (int k = 0; k < pieces.length; k++) {
                  if (index == pieces[k].position) {
                    String imagePath = '';
                    if (pieces[k] is Pawn) {
                      imagePath = pieces[k].isWhite
                          ? 'assets/images/white_pawn.png'
                          : 'assets/images/black_pawn.png';
                    } else if (pieces[k] is Knight) {
                      imagePath = pieces[k].isWhite
                          ? 'assets/images/white_knight.png'
                          : 'assets/images/black_knight.png';
                    } else if (pieces[k] is Bishop) {
                      imagePath = pieces[k].isWhite
                          ? 'assets/images/white_bishop.png'
                          : 'assets/images/black_bishop.png';
                    } else if (pieces[k] is Rook) {
                      imagePath = pieces[k].isWhite
                          ? 'assets/images/white_rook.png'
                          : 'assets/images/black_rook.png';
                    } else if (pieces[k] is King) {
                      imagePath = pieces[k].isWhite
                          ? 'assets/images/white_king.png'
                          : 'assets/images/black_king.png';
                    } else if (pieces[k] is Queen) {
                      imagePath = pieces[k].isWhite
                          ? 'assets/images/white_queen.png'
                          : 'assets/images/black_queen.png';
                    }

                    if (imagePath.isNotEmpty) {
                      return GestureDetector(
                        onTap: () {
                          List<int> possibleMoves = pieces[k].possibleMoves();
                          if (possibleMoves.isNotEmpty) {
                            movePiece(k, possibleMoves[0]);
                          }
                        },
                        child: Container(
                          width: chessBoardSize / 8,
                          height: chessBoardSize / 8,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(imagePath),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      );
                    }
                  }
                }


                return Container(
                  decoration: BoxDecoration(
                    color: isWhite(i, j) ? Colors.white70 : Colors.black45,
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
              }, childCount: 64),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      title: '그냥 체스',
      theme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(
          color: Colors.black, // AppBar의 색상을 검은색으로 변경
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Just Chess'),
        ),
        body: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 55.0), // 왼쪽에 패딩 추가
              child: const ChessBoard(),
            ),
            Expanded(child: SizedBox()), // 남은 공간을 차지하는 빈 공간
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
