import 'package:flutter/material.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';

void main() => runApp(QueensApp());

class QueensApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('8-Queen Problem'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => QueensApp()),
                );
              },
            ),
          ],
        ),
        body: QueensBoard(),
      ),
    );
  }
}

class QueensBoard extends StatefulWidget {
  @override
  _QueensBoardState createState() => _QueensBoardState();
}

class _QueensBoardState extends State<QueensBoard> {
  static const int boardSize = 8;
  List<List<bool>> board = List.generate(
    boardSize,
        (_) => List.generate(boardSize, (_) => false),
  );

  bool hasConflict(int row, int col) {
    for (int i = 0; i < boardSize; i++) {
      if (board[row][i] && i != col) return true;
      if (board[i][col] && i != row) return true;
    }

    for (int i = -boardSize; i < boardSize; i++) {
      if (row + i >= 0 &&
          row + i < boardSize &&
          col + i >= 0 &&
          col + i < boardSize &&
          board[row + i][col + i] &&
          (i != 0)) return true;
      if (row + i >= 0 &&
          row + i < boardSize &&
          col - i >= 0 &&
          col - i < boardSize &&
          board[row + i][col - i] &&
          (i != 0)) return true;
    }

    return false;
  }

  bool anyQueensInConflict() {
    List<int> queenRows = [];
    List<int> queenCols = [];

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (board[row][col]) {
          queenRows.add(row);
          queenCols.add(col);
        }
      }
    }

    for (int i = 0; i < queenRows.length; i++) {
      for (int j = i + 1; j < queenRows.length; j++) {
        int row1 = queenRows[i];
        int col1 = queenCols[i];
        int row2 = queenRows[j];
        int col2 = queenCols[j];

        if (row1 == row2 ||
            col1 == col2 ||
            (row1 - col1 == row2 - col2) ||
            (row1 + col1 == row2 + col2)) {
          return true;
        }
      }
    }

    return false;
  }

  void toggleQueen(int row, int col) {
    setState(() {
      board[row][col] = !board[row][col];
      if (isVictory()) {
        showVictoryDialog();
      }
    });
  }

  bool isVictory() {
    int queenCount = 0;
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (board[row][col]) {
          queenCount++;
          if (hasConflict(row, col)) {
            return false;
          }
        }
      }
    }
    return queenCount == boardSize;
  }

  void showVictoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('승리'),
          content: Text('8개의 퀸을 올바르게 배치했습니다!'),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void clearBoard() {
    setState(() {
      board = List.generate(
        boardSize,
            (_) => List.generate(boardSize, (_) => false),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    bool boardInConflict = anyQueensInConflict();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(boardSize, (row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(boardSize, (col) {
                  bool isQueen = board[row][col];
                  bool isConflict = hasConflict(row, col);
                  Color? cellColor;

                  if (boardInConflict) {
                    cellColor = Colors.red;
                  } else if (isConflict) {
                    cellColor = Colors.green;
                  } else if (isQueen) {
                    cellColor = Colors.grey[200]; // 밝은 색상으로 변경
                  } else {
                    cellColor = Colors.grey[300];
                  }

                  return GestureDetector(
                    onTap: () => toggleQueen(row, col),
                    child: Container(
                      margin: EdgeInsets.all(2),
                      width: 40,
                      height: 40,
                      color: cellColor,
                      child: Center(
                        child: isQueen
                            ? SizedBox(
                          width: 24,
                          height: 24,
                          child: BlackQueen(),
                        )
                            : null,
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: clearBoard,
          child: Text('클리어'),
        ),
      ],
    );
  }
}

