import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flame_audio/flame_audio.dart';
import 'stage.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MountainClimberGame game = MountainClimberGame();

  void restartGame() {
    setState(() {
      // 기존 game을 버리고 새 게임 인스턴스 생성
      game = MountainClimberGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 6,
              child: RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: (RawKeyEvent event) {
                  if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
                    game.currentStage.player.jump();
                  }
                },
                child: Listener(
                  onPointerSignal: (PointerSignalEvent event) {
                    if (event is PointerScrollEvent) {
                      // event를 PointerScrollEvent로 안전하게 사용할 수 있음
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
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.blueGrey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.white70), // 버튼 배경색 설정
                        foregroundColor: WidgetStateProperty.all(Colors.black), // 버튼 텍스트 색상 설정
                      ),
                      onPressed: () {
                        restartGame(); // 여기서 새로운 game 인스턴스를 만들어 교체
                      },
                      child: Text(
                        '재시작',
                      ),
                    ),

                    SizedBox(height: 20),

                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.white70), // 버튼 배경색 설정
                        foregroundColor: WidgetStateProperty.all(Colors.black), // 버튼 텍스트 색상 설정
                      ),
                      onPressed: () {
                        // 설정 버튼 동작
                      },
                      child: Text('설정'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MountainClimberGame extends Forge2DGame {
  MountainClimberGame() : super(gravity: Vector2(0, 100), zoom: 10.0) {
    debugMode = false;
  }

  late Stage currentStage;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    currentStage = Stage1(size);
    add(currentStage);
    await currentStage.loaded; // Stage 로드 대기
  }

  void loadStage(Stage newStage) {
    // 기존 스테이지 제거
    currentStage?.removeFromParent();
    // 새로운 스테이지 추가
    currentStage = newStage;
    add(currentStage);
  }


  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    return currentStage.handleKeyEvent(event, keysPressed);
  }

  void handleMouseScroll(PointerScrollEvent event) {
    currentStage.handleMouseScroll(event);
  }



  void handlePanUpdate(DragUpdateDetails details) {
    currentStage.handlePanUpdate(details);
  }
}


class FloatingPlatform extends BodyComponent {
  final Vector2 position;
  final Vector2 size;

  FloatingPlatform(this.position, this.size);

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(size.x / 2, size.y / 2, Vector2.zero(), 0.0);
    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..friction = 0.5
      ..restitution = 0.0
      ..isSensor = false;

    final bodyDef = BodyDef()
      ..type = BodyType.static
      ..position = position;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

abstract class GravityBodyComponent extends BodyComponent {
  static const double gravityAcceleration = 100;
  final double terminalVelocity = 50000.0;

  @override
  void update(double dt) {
    super.update(dt);
    final gravityForce = Vector2(0, gravityAcceleration * body.mass);
    body.applyForce(gravityForce, point: body.worldCenter);
    final velocity = body.linearVelocity;
    if (velocity.y > terminalVelocity) {
      body.linearVelocity = Vector2(velocity.x, terminalVelocity);
    }
  }

  void resetPosition(Vector2 position) {
    body.setTransform(position, body.angle);
    body.linearVelocity = Vector2.zero();
  }
}

class Background extends Component with HasGameRef {
  @override
  void render(Canvas canvas) {
    final gameSize = game.size;
    final rect = Rect.fromLTWH(0, 0, gameSize.x, gameSize.y);
    final paint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRect(rect, paint);
  }
}

class Ground extends BodyComponent {
  final Vector2 size;

  Ground(this.size);

  @override
  final Paint paint = Paint()..color = const Color(0xFFA0522D);

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(size.x, size.y * 0.05);
    final fixtureDef = FixtureDef(shape)
      ..friction = 0.9
      ..restitution = 0.0
      ..isSensor = false;
    final bodyDef = BodyDef()
      ..type = BodyType.static
      ..position = Vector2(0, size.y);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Mountain extends BodyComponent {
  final List<Vector2> vertices;

  Mountain(this.vertices);

  @override
  final Paint paint = Paint()..color = const Color(0xFF228B22);

  @override
  Body createBody() {
    final shape = PolygonShape()..set(vertices);
    final fixtureDef = FixtureDef(shape)
      ..friction = 0.9
      ..restitution = 0.0
      ..isSensor = false;
    final bodyDef = BodyDef()
      ..type = BodyType.static
      ..position = Vector2.zero();
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}


class DestructibleBox extends BodyComponent with ContactCallbacks {
  final Vector2 position;
  final Vector2 size;
  final double maxHealth;
  double currentHealth;
  final double destructionImpulse;
  final Paint paint = Paint()..color = const Color(0xFFA0522D);
  final Paint crackPaint = Paint()..color = const Color(0xFF000000);

  bool _markedForDestruction = false;

  // 텍스트 페인트
  final TextPaint _textPaint = TextPaint(
    style: const TextStyle(color: Colors.white, fontSize: 12),
  );

  // **변경사항: 크랙 데이터를 저장할 변수 추가**
  Path? crackPath;

  DestructibleBox({
    required this.position,
    required this.size,
    this.maxHealth = 100.0,
    this.destructionImpulse = 80000.0,
  }) : currentHealth = maxHealth;

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(size.x / 2, size.y / 2, Vector2.zero(), 0.0);

    final fixtureDef = FixtureDef(shape)
      ..density = 5.0
      ..friction = 0.8
      ..restitution = 0.2
      ..isSensor = false;

    fixtureDef.filter.categoryBits = 0x0002;
    fixtureDef.filter.maskBits = 0xFFFF;

    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position;

    final boxBody = world.createBody(bodyDef)..createFixture(fixtureDef);
    boxBody.userData = this;
    return boxBody;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_markedForDestruction) {
      world.destroyBody(body);
      removeFromParent();
      _markedForDestruction = false;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 체력바 그리기
    canvas.save();
    canvas.translate(size.x - 50, size.y / 2 - 25);

    final barWidth = size.x;
    final barHeight = 5.0;
    final barOffsetY = -size.y / 2 - 10;
    final healthRatio = currentHealth / maxHealth;
    final currentBarWidth = barWidth * healthRatio;

    final healthBarPaint = Paint()..color = Colors.green;
    canvas.drawRect(
      Rect.fromLTWH(-barWidth / 2, barOffsetY, currentBarWidth, barHeight),
      healthBarPaint,
    );

    final healthText = "${currentHealth.round()}/${maxHealth.round()}";
    final textPainter = _textPaint.toTextPainter(healthText);
    textPainter.layout();
    final textWidth = textPainter.width;
    final textOffset = Vector2(-textWidth / 2, barOffsetY - 15);
    _textPaint.render(canvas, healthText, textOffset);

    // 크랙 렌더링
    if (currentHealth <= maxHealth * 0.5) {
      if (crackPath == null) {
        _generateCracks(); // **변경사항: 크랙이 없을 때만 생성**
      }
      canvas.drawPath(crackPath!, crackPaint); // **변경사항: 기존 크랙을 렌더링**
    }

    canvas.restore();
  }

  // **변경사항: 크랙 생성 메서드 추가**
  void _generateCracks() {
    final random = Random();
    crackPath = Path()..moveTo(0, 0);

    // 메인 크랙 생성
    for (int i = 0; i < 5; i++) {
      double dx = (random.nextDouble() - 0.5) * size.x;
      double dy = (random.nextDouble() - 0.5) * size.y;
      crackPath!.lineTo(dx, dy);
    }

    // 각 분기점에서 작은 크랙 추가
    for (int i = 0; i < 10; i++) {
      final branchPath = Path();
      double startX = (random.nextDouble() - 0.5) * size.x;
      double startY = (random.nextDouble() - 0.5) * size.y;
      branchPath.moveTo(startX, startY);

      for (int j = 0; j < 3; j++) {
        double dx = startX + (random.nextDouble() - 0.5) * size.x * 0.2;
        double dy = startY + (random.nextDouble() - 0.5) * size.y * 0.2;
        branchPath.lineTo(dx, dy);
      }
      crackPath!.addPath(branchPath, Offset.zero); // **변경사항: 작은 크랙 병합**
    }
  }

  @override
  void postSolve(Object other, Contact contact, ContactImpulse impulse) {
    super.postSolve(other, contact, impulse);
    final fixtureA = contact.fixtureA;
    final fixtureB = contact.fixtureB;
    final isSelfA = fixtureA.body == body;
    final otherBody = isSelfA ? fixtureB.body : fixtureA.body;

    if (otherBody.userData == "ball") {
      final maxImpulse = impulse.normalImpulses.reduce((a, b) => a > b ? a : b);
      if (maxImpulse > destructionImpulse) {
        final damage = maxImpulse / 10000;
        currentHealth -= damage;
        print('Box damaged by ball: $damage, Current Health: $currentHealth');
        FlameAudio.play('pow.mp3');
        if (currentHealth <= 0) {
          _markedForDestruction = true;
        }
      }
    }
  }
}






class Player extends GravityBodyComponent with ContactCallbacks, HasGameRef<Forge2DGame> {
  late final SpriteComponent spriteComponent; // 플레이어의 이미지 컴포넌트
  bool isJumpSoundPlaying = false; // 점프 사운드 재생 여부

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // face.png 이미지를 로드하여 스프라이트 생성
    final sprite = await gameRef.loadSprite('face.png');
    spriteComponent = SpriteComponent(
      sprite: sprite,
      size: Vector2(30, 30), // 이미지 크기
      anchor: Anchor.center, // 중심점 기준으로 정렬
    );

    add(spriteComponent); // 이미지 컴포넌트를 추가
  }

  @override
  Body createBody() {
    final gameSize = game.size;
    final shape = CircleShape()..radius = 15; // 충돌 영역은 원형으로 유지
    final fixtureDef = FixtureDef(shape)
      ..density = 6.0
      ..friction = 0.9
      ..restitution = 0.0;
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = Vector2(gameSize.x / 4, gameSize.y / 2);
    final playerBody = world.createBody(bodyDef)..createFixture(fixtureDef);
    playerBody.userData = this;
    return playerBody;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 스프라이트의 위치를 물리 엔진의 월드 좌표로 변환
    spriteComponent.position = Vector2(0, 0);

    // 스프라이트의 회전을 Body의 각도와 동기화
    spriteComponent.angle = body.angle;
  }

  void jump() {
    if (!isJumpSoundPlaying) {
      isJumpSoundPlaying = true; // 재생 시작 표시
      FlameAudio.play('hut.mp3');

      Future.delayed(Duration(milliseconds: 1000), () {
        isJumpSoundPlaying = false; // 1초 후 재생 가능
      });
    }
    final Vector2 currentVelocity = body.linearVelocity;
    double jumpStrength = -200000.0;
    double additionalForceY = jumpStrength - currentVelocity.y;
    body.applyLinearImpulse(Vector2(0, additionalForceY), point: body.worldCenter, wake: true);
  }

  void rotatePlayer(double targetSpeed) {
    double currentSpeed = body.angularVelocity;
    double delta = targetSpeed - currentSpeed;
    double adjustment = delta.clamp(-500.0, 500.0);
    double torque = adjustment * body.mass * 500.0;
    body.applyTorque(torque);
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    super.endContact(other, contact);
  }

  @override
  void preSolve(Object other, Contact contact, Manifold oldManifold) {
    super.preSolve(other, contact, oldManifold);
  }

  @override
  void postSolve(Object other, Contact contact, ContactImpulse impulse) {
    super.postSolve(other, contact, impulse);
  }
}


class BallAndChain extends GravityBodyComponent {
  final Player player;
  late Body ballBody;
  final List<Body> chainBodies = [];
  final Paint chainPaint = Paint()..color = const Color(0xFF808080);
  final Paint ballPaint = Paint()..color = const Color(0xFF808080);

  BallAndChain(this.player);

  static const int chainSegments = 15;
  static const double chainRadius = 2.0;
  static const double ballRadius = 10.0;
  static const double chainSpacing = 0.5;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 플레이어의 body가 초기화될 때까지 대기
    await player.loaded;

    // _createBallAndChain 호출
    _createBallAndChain();
  }

  void _createBallAndChain() {
    Vector2 currentPosition = player.body.position + Vector2(0, -chainRadius * 2);
    Body? previousBody;

    for (int i = 0; i < chainSegments; i++) {
      final chainBodyDef = BodyDef()
        ..type = BodyType.dynamic
        ..position = currentPosition;
      final chainBody = world.createBody(chainBodyDef);
      final chainShape = CircleShape()..radius = chainRadius;
      chainBody.createFixture(
        FixtureDef(chainShape)
          ..density = 4.0
          ..friction = 0.8
          ..restitution = 0.2,
      );

      if (previousBody != null) {
        final distanceJointDef = DistanceJointDef()
          ..bodyA = previousBody
          ..bodyB = chainBody
          ..localAnchorA.setFrom(Vector2(0, 0))
          ..localAnchorB.setFrom(Vector2(0, 0))
          ..length = chainSpacing
          ..frequencyHz = 10.0
          ..dampingRatio = 0.7;
        final distanceJoint = DistanceJoint(distanceJointDef);
        world.createJoint(distanceJoint);
      } else {
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
      currentPosition += Vector2(0, chainSpacing);
    }

    final ballBodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = currentPosition;
    ballBody = world.createBody(ballBodyDef);
    final ballShape = CircleShape()..radius = ballRadius;
    ballBody.createFixture(
      FixtureDef(ballShape)
        ..density = 5.0
        ..friction = 0.8
        ..restitution = 0.2,
    );

    // **변경사항: 철구를 식별하기 위해 userData 설정**
    ballBody.userData = "ball";

    if (previousBody != null) {
      final distanceJointDef = DistanceJointDef()
        ..bodyA = previousBody
        ..bodyB = ballBody
        ..localAnchorA.setFrom(Vector2(0, 0))
        ..localAnchorB.setFrom(Vector2(0, 0))
        ..length = chainSpacing
        ..frequencyHz = 15.0
        ..dampingRatio = 0.3;
      final distanceJoint = DistanceJoint(distanceJointDef);
      world.createJoint(distanceJoint);
    }
  }

  @override
  void render(Canvas canvas) {
    for (final chainBody in chainBodies) {
      final position = chainBody.position;
      canvas.drawCircle(Offset(position.x, position.y), chainRadius, chainPaint);
    }

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





