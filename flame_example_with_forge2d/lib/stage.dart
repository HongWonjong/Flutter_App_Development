import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'main.dart';

class Stage extends Component with HasGameRef<MountainClimberGame> {
  final List<Component> objects; // 스테이지의 모든 구성 요소
  late Player player; // 플레이어를 스테이지에서 관리
  late BallAndChain ballAndChain;

  Stage(Vector2 size, this.objects);

  List<Component> createBoundaries(Vector2 size) {
    final topLeft = Vector2(0, 0);
    final topRight = Vector2(size.x, 0);
    final bottomRight = Vector2(size.x, size.y);
    final bottomLeft = Vector2(0, size.y);

    return [
      Wall(topLeft, topRight),
      Wall(topRight, bottomRight),
      Wall(bottomRight, bottomLeft),
      Wall(bottomLeft, topLeft),
    ];
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 플레이어와 볼-체인 초기화
    player = Player();
    ballAndChain = BallAndChain(player);

    // 모든 구성 요소 추가
    for (final object in objects) {
      await add(object);
    }

    // 경계 벽 추가
    final boundaries = createBoundaries(gameRef.size);
    for (final boundary in boundaries) {
      await add(boundary);
    }

    // 플레이어와 볼-체인 추가
    await add(player);
    await add(ballAndChain);

    // 카메라 설정
    gameRef.camera.follow(player);
  }

  @override
  void onRemove() {
    super.onRemove();
    // 모든 컴포넌트를 제거
    player.removeFromParent();
    ballAndChain.removeFromParent();
    for (final object in objects) {
      object.removeFromParent();
    }
  }

  KeyEventResult handleKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      player.jump(); // **점프 로직 호출**
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void handleMouseScroll(PointerScrollEvent event) {
    if (event.scrollDelta.dy > 0) {
      player.rotatePlayer(50);
    } else if (event.scrollDelta.dy < 0) {
      player.rotatePlayer(-50);
    }
  }

  void handlePanUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 0) {
      player.rotatePlayer(50);
    } else if (details.delta.dx < 0) {
      player.rotatePlayer(-50);
    }
  }
}




class Stage1 extends Stage {

  Stage1(Vector2 size)
      : super(
    size,
    [
      Background(),
      Ground(Vector2(size.x, size.y)),
      Mountain([
        Vector2(0, size.y * 0.95), // 왼쪽 아래
        Vector2(size.x * 0.2, size.y * 0.85),
        Vector2(size.x * 0.3, size.y * 0.8),
        Vector2(size.x * 0.5, size.y * 0.75), // 꼭대기
        Vector2(size.x * 0.7, size.y * 0.8),
        Vector2(size.x * 0.8, size.y * 0.85),
        Vector2(size.x, size.y * 0.95), // 오른쪽 아래
      ]),
      FloatingPlatform(Vector2(300, 100), Vector2(100, 20)),
      FloatingPlatform(Vector2(500, 250), Vector2(100, 20)),
      DestructibleBox(position: Vector2(200, 300), size: Vector2(50, 50)),
      DestructibleBox(position: Vector2(300, 200), size: Vector2(50, 50)),
      DestructibleBox(position: Vector2(400, 200), size: Vector2(50, 50)),

    ],
  );
}

class Stage2 extends Stage {
  Stage2(Vector2 size)
      : super(
      size,
      [
    Background(),
    Ground(Vector2(size.x, size.y)),
    Mountain([
      Vector2(0, size.y * 0.95), // 시작점
      Vector2(size.x * 0.3, size.y * 0.85),
      Vector2(size.x * 0.5, size.y * 0.8), // 꼭대기
      Vector2(size.x * 0.7, size.y * 0.85),
      Vector2(size.x, size.y * 0.95), // 끝점
    ]),
    FloatingPlatform(Vector2(200, 150), Vector2(120, 20)),
    FloatingPlatform(Vector2(600, 300), Vector2(150, 20)),
  ]);
}

