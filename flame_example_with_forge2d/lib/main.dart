import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

void main() {
  final game = MountainClimberGame();
  runApp(
    Listener(
      onPointerSignal: (PointerSignalEvent event) {
        if (event is PointerScrollEvent) {
          game.handleMouseScroll(event);
        }
      },
      child: GestureDetector(
        onPanUpdate: (details) {
          game.handlePanUpdate(details);
        },
        child: GameWidget(game: game),
      ),
    ),
  );
}
class MountainClimberGame extends Forge2DGame {
  MountainClimberGame() : super(gravity: Vector2(0, 200), zoom: 1.0) {
    debugMode = true;
  }

  late final Player player;
  static const double rotateSpeed = 50;


  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(Background());
    add(Ground());
    add(Mountain());

    // 플레이어 추가
    player = Player();
    add(player);

    await player.loaded; // 플레이어가 완전히 로드될 때까지 대기

    // 곡괭이 추가
    final ballAndChain = BallAndChain(player);
    add(ballAndChain);


    camera.follow(player);

    final boundaries = createBoundaries();
    for (final boundary in boundaries) {
      add(boundary);
    }
  }


  List<Component> createBoundaries() {
    final screenSize = size;

    final topLeft = Vector2(0, 0);
    final topRight = Vector2(screenSize.x, 0);
    final bottomRight = Vector2(screenSize.x, screenSize.y);
    final bottomLeft = Vector2(0, screenSize.y);

    return [
      Wall(topLeft, topRight),
      Wall(topRight, bottomRight),
      Wall(bottomRight, bottomLeft),
      Wall(topLeft, bottomLeft),
    ];
  }

  void handleMouseScroll(PointerScrollEvent event) {
    // 마우스 스크롤 방향에 따라 플레이어 회전 속도 조정
    if (event.scrollDelta.dy > 0) {
      player.rotatePlayer(rotateSpeed); // 시계 방향 회전
    } else if (event.scrollDelta.dy < 0) {
      player.rotatePlayer(-rotateSpeed); // 반시계 방향 회전
    }
  }

  void handlePanUpdate(DragUpdateDetails details) {
    // 드래그 방향에 따라 플레이어 회전 속도 조정
    if (details.delta.dx > 0) {
      player.rotatePlayer(rotateSpeed); // 시계 방향 회전
    } else if (details.delta.dx < 0) {
      player.rotatePlayer(-rotateSpeed); // 반시계 방향 회전
    }
  }




}

class Background extends Component with HasGameRef {
  @override
  void render(Canvas canvas) {
    final gameSize = game.size;
    final rect = Rect.fromLTWH(
      0,
      0,
      gameSize.x,
      gameSize.y,
    );

    final paint = Paint()..color = const Color(0xFF87CEEB); // 하늘색
    canvas.drawRect(rect, paint);
  }
}


class Ground extends BodyComponent {
  @override
  final Paint paint = Paint()..color = const Color(0xFFA0522D); // 갈색



  @override
  Body createBody() {
    final gameSize = game.size;
    final shape = PolygonShape()
      ..setAsBoxXY(gameSize.x, gameSize.y * 0.05); // 가로 50, 세로 5 크기의 박스

    final fixtureDef = FixtureDef(shape)..friction = 0.8;
    final bodyDef = BodyDef()
      ..type = BodyType.static
      ..position = Vector2(0, gameSize.y); // 위치 조정

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Mountain extends BodyComponent {
  @override
  final Paint paint = Paint()..color = const Color(0xFF228B22); // 초록색

  @override
  Body createBody() {
    final gameSize = game.size;

    // 산의 너비와 높이를 더 완만하게 설정
    final mountainWidth = gameSize.x * 0.6; // 약간 더 넓게 설정
    final mountainHeight = gameSize.y * 0.3; // 더 낮게 설정

    // 땅의 높이를 고려하여 산의 위치 조정
    final groundHeight = gameSize.y * 0.05; // 땅이 화면 높이의 5%를 차지한다고 가정
    final yBase = gameSize.y - groundHeight; // 땅 위에 산의 베이스 위치 설정

    // 산의 꼭지점 좌표를 더 완만하게 정의
    final vertices = [
      Vector2(-mountainWidth / 2, 0),                       // 좌측 베이스
      Vector2(-mountainWidth / 4, -mountainHeight / 4),     // 좌측 완만한 중간
      Vector2(0, -mountainHeight),                          // 산의 꼭대기
      Vector2(mountainWidth / 4, -mountainHeight / 4),      // 우측 완만한 중간
      Vector2(mountainWidth / 2, 0),                        // 우측 베이스
    ];

    final shape = PolygonShape()..set(vertices);
    final fixtureDef = FixtureDef(shape)..friction = 0.9;
    final bodyDef = BodyDef()
      ..type = BodyType.static
      ..position = Vector2(gameSize.x / 2, yBase); // 화면 중앙에 산을 배치

    return world.createBody(bodyDef)..createFixture(FixtureDef(shape)..friction = 0.8);
  }
}


class Player extends BodyComponent {
  @override
  final Paint paint = Paint()..color = const Color(0xFFFFA500); // 주황색
  double rotationSpeed = 200.0; // 회전 속도
  late BallAndChain ballAndChain; // 곡괭이 참조 추가

  Player() {
    ballAndChain = BallAndChain(this); // 곡괭이 초기화
  }


  @override
  Body createBody() {
    final gameSize = game.size;
    final shape = CircleShape()..radius = 15;
    final fixtureDef = FixtureDef(shape)
      ..density = 4.0
      ..friction = 0.9;
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = Vector2(gameSize.x / 4, gameSize.y / 2);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void rotatePlayer(double speed) {
    rotationSpeed = speed;
    body.angularVelocity = rotationSpeed; // 플레이어 회전 속도 설정

  }

}

class BallAndChain extends BodyComponent {
  final Player player;
  late Body ballBody; // 철구 Body
  final List<Body> chainBodies = []; // 쇠사슬 구들
  final Paint chainPaint = Paint()..color = const Color(0xFF8B4513); // 진갈색 (쇠사슬)
  final Paint ballPaint = Paint()..color = const Color(0xFF808080); // 회색 (철구)

  BallAndChain(this.player);

  static const int chainSegments = 5; // 쇠사슬 구 개수
  static const double chainRadius = 2.0; // 쇠사슬 구 반지름
  static const double ballRadius = 10.0; // 철구 반지름
  static const double chainSpacing = 5.0; // 구 사이 간격

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await Future.delayed(Duration.zero);
    _createBallAndChain();
  }

  void _createBallAndChain() {
    // 플레이어 Body의 시작 위치
    Vector2 currentPosition = player.body.position + Vector2(0, -chainRadius * 2);

    Body? previousBody; // 이전 Body 참조

    // 쇠사슬 구 생성
    for (int i = 0; i < chainSegments; i++) {
      final chainBodyDef = BodyDef()
        ..type = BodyType.dynamic
        ..position = currentPosition;

      final chainBody = world.createBody(chainBodyDef);

      final chainShape = CircleShape()..radius = chainRadius;
      chainBody.createFixture(
        FixtureDef(chainShape)
          ..density = 0.5
          ..friction = 0.8
          ..restitution = 0.2,
      );

      if (previousBody != null) {
        // 이전 구와 현재 구를 DistanceJoint로 연결
        final distanceJointDef = DistanceJointDef()
          ..bodyA = previousBody
          ..bodyB = chainBody
          ..localAnchorA.setFrom(Vector2(0, 0))
          ..localAnchorB.setFrom(Vector2(0, 0))
          ..length = chainSpacing
          ..frequencyHz = 5.0 // 스프링 효과
          ..dampingRatio = 0.7; // 감쇠 효과

        final distanceJoint = DistanceJoint(distanceJointDef);
        world.createJoint(distanceJoint);
      } else {
        // 첫 번째 구는 플레이어 Body와 연결
        final revoluteJointDef = RevoluteJointDef()
          ..bodyA = player.body
          ..bodyB = chainBody
          ..localAnchorA.setFrom(Vector2(0, -2))
          ..localAnchorB.setFrom(Vector2(0, 0));

        final revoluteJoint = RevoluteJoint(revoluteJointDef);
        world.createJoint(revoluteJoint);
      }

      chainBodies.add(chainBody);
      previousBody = chainBody;
      currentPosition += Vector2(0, chainSpacing); // 다음 구 위치로 이동
    }

    // 철구 생성
    final ballBodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = currentPosition;

    ballBody = world.createBody(ballBodyDef);

    final ballShape = CircleShape()..radius = ballRadius;
    ballBody.createFixture(
      FixtureDef(ballShape)
        ..density = 1.0
        ..friction = 0.8
        ..restitution = 0.2,
    );

    // 마지막 쇠사슬 구와 철구를 연결
    if (previousBody != null) {
      final distanceJointDef = DistanceJointDef()
        ..bodyA = previousBody
        ..bodyB = ballBody
        ..localAnchorA.setFrom(Vector2(0, 0))
        ..localAnchorB.setFrom(Vector2(0, 0))
        ..length = chainSpacing
        ..frequencyHz = 5.0
        ..dampingRatio = 0.7;

      final distanceJoint = DistanceJoint(distanceJointDef);
      world.createJoint(distanceJoint);
    }
  }

  @override
  void render(Canvas canvas) {
    // 쇠사슬 구 렌더링
    for (final chainBody in chainBodies) {
      final position = chainBody.position;
      canvas.drawCircle(Offset(position.x, position.y), chainRadius, chainPaint);
    }

    // 철구 렌더링
    final ballPosition = ballBody.position;
    canvas.drawCircle(Offset(ballPosition.x, ballPosition.y), ballRadius, ballPaint);
  }

  @override
  Body createBody() {
    return world.createBody(BodyDef());
  }
}




class Wall extends BodyComponent {
  final Vector2 _start;
  final Vector2 _end;

  Wall(this._start, this._end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(_start, _end);
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(type: BodyType.static);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}




