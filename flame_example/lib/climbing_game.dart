import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'mountain.dart';
import 'player.dart';
import 'pickaxe.dart';
import 'ground.dart';

class ClimbingGame extends FlameGame {
  late Player player;
  late Pickaxe pickaxe;
  late List<PositionComponent> objects; // 충돌 대상 리스트
  late Ground ground;

  @override
  Future<void> onLoad() async {
    // 충돌 대상 오브젝트 초기화
    ground = Ground();
    final mountain = Mountain();

    // 플레이어 초기화
    player = Player(Vector2(200, ground.position.y - 150)); // 초기 위치: 땅 위

    // 곡괭이 초기화 및 게임 루트에 추가
    pickaxe = Pickaxe(player);
    player.pickaxe = pickaxe; // 플레이어에 곡괭이 설정
    add(pickaxe); // 곡괭이를 게임 루트에 추가

    // 충돌 대상 리스트에 플레이어와 곡괭이를 포함
    objects = [
      ground,     // 땅
      mountain,   // 산
      player,     // 플레이어
      pickaxe,    // 곡괭이
    ];

    // 게임에 오브젝트 추가
    add(ground);
    add(mountain);
    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 곡괭이 회전 처리
    const rotationSpeed = 1.0; // 회전 속도 (라디안/초)
    pickaxe.rotate(rotationSpeed * dt, objects);

    // 플레이어 이동 처리
    player.move(dt, objects);

    // 곡괭이의 고정 해제 조건 (예: 일정 시간 후 해제)
    if (pickaxe.isAttached) {
      // 임시로 2초 후에 곡괭이 고정 해제
      // 실제로는 사용자 입력 또는 다른 조건을 사용해야 함
      Future.delayed(Duration(seconds: 2), () {
        pickaxe.detach();
      });
    }
  }
}


