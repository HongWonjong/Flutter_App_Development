import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Ground extends PositionComponent {
  Ground() {
    size = Vector2(800, 100); // 땅의 크기 (가로 800, 세로 50)
    position = Vector2(0, 500); // 화면 하단에 위치 (예시)
  }

  @override
  void render(Canvas canvas) {
    Paint paint = Paint()..color = Colors.green;
    canvas.drawRect(size.toRect(), paint); // 녹색 사각형
  }
}
