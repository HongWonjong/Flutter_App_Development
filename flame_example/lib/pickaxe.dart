import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'mountain.dart';
import 'player.dart';

class Pickaxe extends PositionComponent {
  final Player player; // 플레이어 참조
  double headWidth = 80; // 곡괭이 머리의 너비
  double headHeight = 10; // 곡괭이 머리의 높이

  bool isAttached = false; // 곡괭이가 고정되었는지 여부
  Vector2? attachedPoint; // 곡괭이가 고정된 위치

  Pickaxe(this.player) {
    size = Vector2(15, 120); // 막대 크기 (손잡이 길이 증가)
    anchor = Anchor.bottomCenter; // 앵커를 BottomCenter로 설정
    position = player.position + Vector2(player.size.x / 2, 0); // 플레이어의 상단 중앙에 위치
    debugMode = true; // 디버그 모드 활성화 (필요시)
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 막대기(손잡이) 렌더링
    final stickPaint = Paint()..color = Colors.orangeAccent;
    final stickRect = Rect.fromLTWH(-size.x / 2, -size.y, size.x, size.y);
    canvas.drawRect(stickRect, stickPaint);

    // 곡괭이 머리 렌더링 (막대 위쪽에 위치)
    final headPaint = Paint()..color = Colors.grey;
    final headRect = Rect.fromLTWH(
      -headWidth / 2, // 중앙 정렬
      -size.y - headHeight, // 막대 위쪽에 위치
      headWidth,
      headHeight,
    );
    canvas.drawRect(headRect, headPaint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isAttached) {
      // 곡괭이가 고정되지 않은 경우에만 플레이어 위치에 따라 이동
      position = player.position + Vector2(player.size.x / 2, 0);
    }
    // 곡괭이가 고정된 경우 위치를 변경하지 않음
  }

  /// 곡괭이 머리의 충돌 영역 계산
  Vector2 getTip() {
    // 전역 위치와 전역 각도를 사용하여 tip 좌표 계산
    final globalPosition = absolutePosition;
    final globalAngle = absoluteAngle;

    final tipOffset = Vector2(0, -size.y)
      ..rotate(globalAngle);
    return globalPosition + tipOffset;
  }

  /// 충돌 가능한 위치인지 확인 (곡괭이 머리 부분만 검사)
  bool canMoveTo(Vector2 tip, List<PositionComponent> objects) {
    if (isAttached) {
      // 곡괭이가 고정된 상태에서는 충돌 검사를 수행하지 않음
      return false;
    }

    for (final object in objects) {
      // 플레이어는 충돌 검사에서 제외
      if (object == player) continue;

      if (object is Mountain) {
        // 산과의 충돌 검사
        if (object.containsPoint(tip)) {
          return false; // 충돌 발생
        }
      } else if (object.toRect().contains(tip.toOffset())) {
        // Rect 기반 오브젝트와의 충돌 검사 (예: Ground)
        return false;
      }
    }
    return true; // 이동 가능
  }

  /// 곡괭이 회전
  void rotate(double deltaAngle, List<PositionComponent> objects) {
    if (isAttached) {
      // 곡괭이가 고정된 상태에서는 회전하지 않음
      return;
    }

    // 회전 후의 전역 각도 계산
    final nextAngle = angle + deltaAngle;
    final globalNextAngle = nextAngle; // 부모가 없으므로 그냥 nextAngle 사용

    // 회전 후의 tip 좌표 계산
    final globalPosition = absolutePosition;
    final tipOffset = Vector2(0, -size.y)
      ..rotate(globalNextAngle);
    final tip = globalPosition + tipOffset;

    // 충돌 검사
    if (canMoveTo(tip, objects)) {
      angle = nextAngle % (2 * pi); // 회전 허용
    } else {
      // 충돌 발생 시 곡괭이를 고정
      isAttached = true;
      attachedPoint = tip.clone();
    }
  }

  /// 곡괭이 고정 해제
  void detach() {
    isAttached = false;
    attachedPoint = null;
  }
}



