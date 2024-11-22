import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'mountain.dart';
import 'pickaxe.dart';

class Player extends PositionComponent with HasGameRef {
  double gravity = 500; // 중력 가속도 (px/s^2)
  double velocityY = 0; // 수직 속도

  // 곡괭이 참조 추가 (nullable로 선언)
  Pickaxe? pickaxe;

  Player(Vector2 startPosition) {
    size = Vector2(50, 50); // 플레이어 크기
    position = startPosition; // 초기 위치
    debugMode = true; // 디버그 모드 활성화 (필요시)
  }

  @override
  void render(Canvas canvas) {
    Paint paint = Paint()..color = Colors.blue;
    canvas.drawRect(size.toRect(), paint); // 파란 사각형
  }

  void move(double dt, List<PositionComponent> objects) {
    if (pickaxe != null && pickaxe!.isAttached) {
      // 곡괭이가 고정된 상태에서 플레이어 이동 로직
      // 필요에 따라 구현
    } else {
      // 곡괭이가 고정되지 않은 경우 중력 적용
      applyGravity(dt, objects);
    }
  }


  void moveWithPickaxe(double dt, List<PositionComponent> objects) {
    // 이동 계산 (예시로 단순히 위로 이동)
    Vector2 offset = Vector2(0, -100 * dt);
    Vector2 newPosition = position + offset;

    // 충돌 검사
    if (!isColliding(newPosition, objects)) {
      position = newPosition;
    } else {
      // 충돌 시 이동 중단 또는 위치 조정
    }
  }

  /// 중력 적용
  void applyGravity(double dt, List<PositionComponent> objects) {
    // 중력 가속도 적용
    velocityY += gravity * dt;
    double dy = velocityY * dt;

    // 새로운 위치 계산
    final newPosition = position + Vector2(0, dy);

    // 충돌 검사
    if (!isColliding(newPosition, objects)) {
      position = newPosition;
    } else {
      // 충돌 시 위치 조정 및 속도 초기화
      velocityY = 0;
      // 위치를 오브젝트의 상단에 맞게 조정
    }
  }

  /// 플레이어가 오브젝트와 충돌했는지 확인
  bool isColliding(Vector2 newPosition, List<PositionComponent> objects) {
    final playerRect = Rect.fromLTWH(newPosition.x, newPosition.y, size.x, size.y);

    for (final object in objects) {
      // 곡괭이는 충돌 검사에서 제외
      if (object == pickaxe) continue;

      if (object is Mountain) {
        // 산과의 충돌 처리
        if (object.containsPoint(newPosition + size / 2)) {
          return true; // 산 내부에 포함되면 충돌
        }
      } else if (object.toRect().overlaps(playerRect)) {
        // 일반 Rect 기반 오브젝트와의 충돌 처리
        return true;
      }
    }
    return false; // 충돌 없음
  }

  void checkBounds() {
    final screenSize = gameRef.size;

    // X 좌표 제한
    if (position.x < 0) {
      position.x = 0;
    } else if (position.x + size.x > screenSize.x) {
      position.x = screenSize.x - size.x;
    }

    // Y 좌표 제한
    if (position.y < 0) {
      position.y = 0;
      velocityY = 0;
    } else if (position.y + size.y > screenSize.y) {
      position.y = screenSize.y - size.y;
      velocityY = 0;
    }
  }
}
