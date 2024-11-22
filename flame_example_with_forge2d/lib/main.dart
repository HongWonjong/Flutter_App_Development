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
    final pickaxe = Pickaxe(player);
    add(pickaxe);

    camera.follow(player);

    final boundaries = createBoundaries();
    for (final boundary in boundaries) {
      add(boundary);
    }
  }


  List<Component> createBoundaries() {
    final screenSize = size;

    final topLeft = Vector2(-screenSize.x, -screenSize.y);
    final topRight = Vector2(screenSize.x, -screenSize.y);
    final bottomRight = Vector2(screenSize.x, screenSize.y);
    final bottomLeft = Vector2(-screenSize.x, screenSize.y);

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
      player.rotatePlayer(10.0); // 시계 방향 회전
    } else if (event.scrollDelta.dy < 0) {
      player.rotatePlayer(-10.0); // 반시계 방향 회전
    }
  }

  void handlePanUpdate(DragUpdateDetails details) {
    // 드래그 방향에 따라 플레이어 회전 속도 조정
    if (details.delta.dx > 0) {
      player.rotatePlayer(10.0); // 시계 방향 회전
    } else if (details.delta.dx < 0) {
      player.rotatePlayer(-10.0); // 반시계 방향 회전
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

    // 산의 너비와 높이를 게임 화면의 절반 크기로 설정
    final mountainWidth = gameSize.x * 0.5;
    final mountainHeight = gameSize.y * 0.5;

    // 땅의 높이를 고려하여 산의 위치 조정
    final groundHeight = gameSize.y * 0.05; // 땅이 화면 높이의 10%를 차지한다고 가정
    final yBase = gameSize.y - groundHeight; // 땅 위에 산의 베이스 위치 설정

    // 산의 꼭지점 좌표를 바디의 위치를 기준으로 상대적으로 정의
    final vertices = [
      Vector2(-mountainWidth / 2, 0),                      // 좌측 베이스
      Vector2(-mountainWidth / 4, -mountainHeight / 2),    // 좌측 중간
      Vector2(0, -mountainHeight),                         // 산의 꼭대기
      Vector2(mountainWidth / 4, -mountainHeight / 2),     // 우측 중간
      Vector2(mountainWidth / 2, 0),                       // 우측 베이스
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
  double rotationSpeed = 100.0; // 회전 속도
  late Pickaxe pickaxe; // 곡괭이 참조 추가

  @override
  Body createBody() {
    final gameSize = game.size;
    final shape = CircleShape()..radius = 10;
    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..friction = 0.5;
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = Vector2(gameSize.x / 4, gameSize.y / 2);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void rotatePlayer(double speed) {
    rotationSpeed = speed;
    body.angularVelocity = rotationSpeed; // 플레이어 회전 속도 설정

    // 곡괭이의 모터 속도와 동기화
    pickaxe.rotatePickaxe(rotationSpeed);
  }

}


class Pickaxe extends BodyComponent {
  final Player player;
  late Body pickaxeBody;
  final Paint handlePaint = Paint()..color = const Color(0xFF8B4513); // 진갈색
  final Paint bladePaint = Paint()..color = const Color(0xFF808080); // 회색
  RevoluteJoint? joint; // 조인트 참조

  Pickaxe(this.player);

  double motorSpeed = 0.0; // 기본 회전 속도
  // 곡괭이 크기 및 위치 설정
  static const double handleWidth = 2.0; // 막대기 폭
  static const double handleHeight = 30.0; // 막대기 높이
  static const double bladeWidth = 17.0; // 날 폭
  static const double bladeHeight = 3.0; // 날 높이
  static const double bladeOffsetY = -30.0; // 날 위치(막대 기준)



  @override
  void render(Canvas canvas) {
    final position = pickaxeBody.position;
    final angle = pickaxeBody.angle;

    // 막대기 부분
    canvas.save();
    canvas.translate(position.x, position.y);
    canvas.rotate(angle);
    canvas.drawRect(
      Rect.fromCenter(
        center: const Offset(0, -handleHeight / 2 + 3),
        width: handleWidth,
        height: handleHeight,
      ),
      handlePaint,
    );
    canvas.restore();

    // 날 부분
    canvas.save();
    final bladeOffset = _rotateOffset(const Offset(0, bladeOffsetY + 3), angle);
    canvas.translate(position.x + bladeOffset.dx, position.y + bladeOffset.dy);
    canvas.rotate(angle);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: bladeWidth,
        height: bladeHeight,
      ),
      bladePaint,
    );
    canvas.restore();
  }


  Offset _rotateOffset(Offset localOffset, double angle) {
    final rotatedX = localOffset.dx * cos(angle) - localOffset.dy * sin(angle);
    final rotatedY = localOffset.dx * sin(angle) + localOffset.dy * cos(angle);
    return Offset(rotatedX, rotatedY);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await Future.delayed(Duration.zero);
    _createPickaxe();
  }

  void _createPickaxe() {
    // 막대 모양 정의
    final handleShape = PolygonShape()
      ..setAsBoxXY(handleWidth / 2, handleHeight / 2); // 폭, 높이 반으로 설정

    // 날 모양 정의
    final bladeShape = PolygonShape()
      ..set([
        Vector2(-bladeWidth / 2, bladeOffsetY), // 날 왼쪽
        Vector2(bladeWidth / 2, bladeOffsetY),  // 날 오른쪽
        Vector2(0, bladeOffsetY - bladeHeight), // 날 꼭대기
      ]);

    final pickaxeBodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = player.body.position + Vector2(0, -5);

    pickaxeBody = world.createBody(pickaxeBodyDef);

    // 막대 부분
    pickaxeBody.createFixture(
        FixtureDef(handleShape)
          ..density = 0.5
          ..friction = 0.8
    );

    // 날 부분
    pickaxeBody.createFixture(
      FixtureDef(bladeShape)
        ..density = 1.0
        ..friction = 0.8
        ..restitution = 0.2,
    );

    final revoluteJointDef = RevoluteJointDef()
      ..bodyA = player.body
      ..bodyB = pickaxeBody
      ..localAnchorA.setFrom(Vector2(0, -2))
      ..localAnchorB.setFrom(Vector2(0, handleHeight / 2))
      ..enableMotor = true
      ..motorSpeed = motorSpeed
      ..maxMotorTorque = 5000;


    // RevoluteJoint 생성
    final revoluteJoint = RevoluteJoint(revoluteJointDef);
    joint = revoluteJoint; // 조인트를 필드에 저장

    // World에 조인트 추가
    world.createJoint(revoluteJoint);
  }
  void rotatePickaxe(double speed) {
    motorSpeed = speed;
    if (joint != null) {
      joint!.motorSpeed = motorSpeed;
      joint!.enableMotor(true); // 모터 활성화
    }
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




