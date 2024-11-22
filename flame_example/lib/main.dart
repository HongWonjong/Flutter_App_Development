import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'climbing_game.dart';

void main() {
  final climbingGame = ClimbingGame();

  runApp(MaterialApp(
    home: Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          final delta = details.delta.dx;
          climbingGame.pickaxe.rotate(delta * 0.01, climbingGame.objects); // 충돌 검사 포함
        },
        child: GameWidget(game: climbingGame),
      ),
    ),
  ));
}
