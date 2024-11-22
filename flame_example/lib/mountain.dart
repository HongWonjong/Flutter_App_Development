import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Mountain extends PositionComponent {
  late Path path;

  Mountain() {
    size = Vector2(300, 400); // 산 크기
    position = Vector2(150, 50); // 땅 위에 적절히 배치
    path = Path(); // Path 초기화
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Path 초기화
    path = Path()
      ..moveTo(position.x + size.x / 2, position.y) // 꼭대기
      ..lineTo(position.x + size.x, position.y + size.y) // 오른쪽 아래
      ..lineTo(position.x, position.y + size.y) // 왼쪽 아래
      ..close();
  }

  @override
  void render(Canvas canvas) {
    Paint paint = Paint()..color = Colors.brown;
    canvas.drawPath(path, paint); // Path를 그리기
  }

  /// 특정 좌표가 산 내부에 포함되는지 확인
  bool containsPoint(Vector2 point) {
    return path.contains(point.toOffset());
  }
}


