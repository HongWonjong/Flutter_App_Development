import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'object.dart';

class Stage extends Component with HasGameRef<MountainClimberGame> {
  final List<Component> objects; // 스테이지의 모든 구성 요소
  late Player player; // 플레이어를 스테이지에서 관리
  late BallAndChain ballAndChain;
  late HealthBar healthBar;

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
    healthBar = HealthBar(player);

    // 모든 구성 요소 추가
    for (final object in objects) {
      await add(object);
    }

    // **여기서 Turret에게 Player 할당**
    for (final object in objects) {
      if (object is Turret) {
        object.setPlayer(player);
      }
    }

    // 경계 벽 추가
    final boundaries = createBoundaries(gameRef.size);
    for (final boundary in boundaries) {
      await add(boundary);
    }

    // 플레이어와 볼-체인 추가
    await add(player);
    await add(ballAndChain);
    await add(healthBar);

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
  void handlePlayerDeath() {
    // Notify gameRef to show game over screen
    gameRef.showGameOver();

    // Remove player and ball-and-chain
    player.removeFromParent();
    ballAndChain.removeFromParent();
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
      Turret(Vector2(600, 200)), // 여기서 터렛 추가

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
        DestructibleBox(position: Vector2(200, 300), size: Vector2(50, 50)),
        DestructibleBox(position: Vector2(300, 200), size: Vector2(50, 50)),
        DestructibleBox(position: Vector2(400, 200), size: Vector2(50, 50)),
        Turret(Vector2(500, 200)), // 여기서 터렛 추가
      ]);
}

class Stage3 extends Stage {
  Stage3(Vector2 size)
      : super(
    size,
    [
      Background(),
      Ground(Vector2(size.x, size.y)),
      Mountain([
        Vector2(0, size.y * 0.95),
        Vector2(size.x * 0.2, size.y * 0.85),
        Vector2(size.x * 0.5, size.y * 0.75),
        Vector2(size.x * 0.8, size.y * 0.85),
        Vector2(size.x, size.y * 0.95),
      ]),
      FloatingPlatform(Vector2(300, 200), Vector2(100, 20)),
      FloatingPlatform(Vector2(500, 100), Vector2(150, 30)),
      DestructibleBox(position: Vector2(250, 250), size: Vector2(50, 50)),
      DestructibleBox(position: Vector2(350, 200), size: Vector2(50, 50)),
      DestructibleBox(position: Vector2(150, 200), size: Vector2(50, 50)),
      Turret(Vector2(500, 100)), // 여기서 터렛 추가

    ],
  );
}

class Stage4 extends Stage {
  Stage4(Vector2 size)
      : super(
    size,
    [
      Background(),
      Ground(Vector2(size.x, size.y)),
      Mountain([
        Vector2(0, size.y * 0.95),
        Vector2(size.x * 0.1, size.y * 0.85),
        Vector2(size.x * 0.3, size.y * 0.8),
        Vector2(size.x * 0.6, size.y * 0.85),
        Vector2(size.x, size.y * 0.95),
      ]),
      FloatingPlatform(Vector2(150, 250), Vector2(120, 20)),
      FloatingPlatform(Vector2(550, 350), Vector2(150, 30)),
      DestructibleBox(position: Vector2(100, 300), size: Vector2(50, 50)),
      DestructibleBox(position: Vector2(400, 200), size: Vector2(50, 50)),
      DestructibleBox(position: Vector2(250, 100), size: Vector2(50, 50)),

    ],
  );
}

class Stage5 extends Stage {
  Stage5(Vector2 size)
      : super(
    size,
    [
      Background(),
      Ground(Vector2(size.x, size.y)),
      Mountain([
        Vector2(0, size.y * 0.95),
        Vector2(size.x * 0.25, size.y * 0.85),
        Vector2(size.x * 0.5, size.y * 0.75),
        Vector2(size.x * 0.75, size.y * 0.85),
        Vector2(size.x, size.y * 0.95),
      ]),
      FloatingPlatform(Vector2(200, 200), Vector2(100, 20)),
      FloatingPlatform(Vector2(400, 100), Vector2(150, 30)),
      DestructibleBox(position: Vector2(300, 300), size: Vector2(50, 50)),
      DestructibleBox(position: Vector2(400, 250), size: Vector2(50, 50)),
      DestructibleBox(position: Vector2(500, 200), size: Vector2(50, 50)),

    ],
  );
}

class Stage6 extends Stage {
  Stage6(Vector2 size)
      : super(
    size,
    [
      Background(),
      Ground(Vector2(size.x, size.y)),
      Mountain([
        Vector2(0, size.y * 0.95),
        Vector2(size.x * 0.3, size.y * 0.85),
        Vector2(size.x * 0.6, size.y * 0.75),
        Vector2(size.x * 0.9, size.y * 0.85),
        Vector2(size.x, size.y * 0.95),
      ]),
      FloatingPlatform(Vector2(250, 150), Vector2(120, 20)),
      FloatingPlatform(Vector2(450, 250), Vector2(150, 30)),
      DestructibleBox(position: Vector2(200, 300), size: Vector2(50, 50)),
      DestructibleBox(position: Vector2(400, 200), size: Vector2(50, 50)),
    ],
  );
}

class Stage7 extends Stage {
  Stage7(Vector2 size)
      : super(
    size,
    [
      Background(),
      Ground(Vector2(size.x, size.y)),
      Mountain([
        Vector2(0, size.y * 0.95),
        Vector2(size.x * 0.4, size.y * 0.75),
        Vector2(size.x * 0.6, size.y * 0.65),
        Vector2(size.x, size.y * 0.95),
      ]),
      FloatingPlatform(Vector2(300, 250), Vector2(100, 20)),
      FloatingPlatform(Vector2(600, 150), Vector2(150, 30)),
      DestructibleBox(position: Vector2(200, 300), size: Vector2(50, 50)),
    ],
  );
}

class Stage8 extends Stage {
  Stage8(Vector2 size)
      : super(
    size,
    [
      Background(),
      Ground(Vector2(size.x, size.y)),
      Mountain([
        Vector2(0, size.y * 0.95),
        Vector2(size.x * 0.2, size.y * 0.85),
        Vector2(size.x * 0.5, size.y * 0.75),
        Vector2(size.x * 0.8, size.y * 0.85),
        Vector2(size.x, size.y * 0.95),
      ]),
      FloatingPlatform(Vector2(150, 300), Vector2(120, 20)),
      FloatingPlatform(Vector2(500, 100), Vector2(150, 30)),
      DestructibleBox(position: Vector2(300, 200), size: Vector2(50, 50)),
    ],
  );
}

class Stage9 extends Stage {
  Stage9(Vector2 size)
      : super(
    size,
    [
      Background(),
      Ground(Vector2(size.x, size.y)),
      Mountain([
        Vector2(0, size.y * 0.95),
        Vector2(size.x * 0.15, size.y * 0.85),
        Vector2(size.x * 0.35, size.y * 0.75),
        Vector2(size.x * 0.7, size.y * 0.85),
        Vector2(size.x, size.y * 0.95),
      ]),
      FloatingPlatform(Vector2(300, 200), Vector2(100, 20)),
      FloatingPlatform(Vector2(550, 150), Vector2(150, 30)),
      DestructibleBox(position: Vector2(250, 250), size: Vector2(50, 50)),
    ],
  );
}

class Stage10 extends Stage {
  Stage10(Vector2 size)
      : super(
    size,
    [
      Background(),
      Ground(Vector2(size.x, size.y)),
      Mountain([
        Vector2(0, size.y * 0.95),
        Vector2(size.x * 0.3, size.y * 0.85),
        Vector2(size.x * 0.5, size.y * 0.75),
        Vector2(size.x * 0.7, size.y * 0.85),
        Vector2(size.x, size.y * 0.95),
      ]),
      FloatingPlatform(Vector2(200, 250), Vector2(120, 20)),
      FloatingPlatform(Vector2(600, 200), Vector2(150, 30)),
      DestructibleBox(position: Vector2(150, 300), size: Vector2(50, 50)),
      DestructibleBox(position: Vector2(450, 250), size: Vector2(50, 50)),
    ],
  );
}


