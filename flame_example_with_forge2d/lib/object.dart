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

import 'main.dart';


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
  bool isBlinking = false; // 깜빡임 상태 플래그


  double maxHealth = 100.0;
  double currentHealth = 100.0;

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
  void takeDamage(double damage) {
    currentHealth -= damage;
    print('Player damaged: -$damage, Current Health: $currentHealth');
    if (!isBlinking) {
      _blink(); // 맞았을 때 깜빡임 효과 실행
    }

    if (currentHealth <= 0) {
      currentHealth = 0;
      _onDeath();
    }
  }

  void _onDeath() {
    FlameAudio.play('died.mp3');

    (gameRef as MountainClimberGame).currentStage.handlePlayerDeath();
  }
  void _blink() {
    isBlinking = true;

    // 스프라이트를 어둡게 변경
    spriteComponent.paint.color = Colors.black.withOpacity(0.5);

    // 일정 시간 후 원래 색상 복구
    Future.delayed(const Duration(milliseconds: 200), () {
      spriteComponent.paint.color = Colors.white; // 기본 색상 복원
      isBlinking = false;
    });
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
    double jumpStrength = -2000000.0;
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
// 화면 왼쪽 상단에 표시할 HealthBar 컴포넌트
class HealthBar extends PositionComponent with HasGameRef<Forge2DGame> {
  final Player player;
  HealthBar(this.player);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 화면 좌측 상단 고정 위치 (카메라 변환 영향 안 받으려면 HUD 전용 레이어나 camera 속성 조정 필요)
    // 여기서는 단순히 절대 좌표를 사용한다고 가정
    position = Vector2(20, 20);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 플레이어 체력 읽기
    double maxHealth = player.maxHealth;
    double currentHealth = player.currentHealth;

    final barWidth = 100.0;
    final barHeight = 10.0;
    final healthRatio = currentHealth / maxHealth;
    final currentBarWidth = barWidth * healthRatio;

    // 빨간 바
    final healthBarPaint = Paint()..color = Colors.red;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, currentBarWidth, barHeight),
      healthBarPaint,
    );

    // 흰색 글씨
    final textPaint = TextPaint(
      style: const TextStyle(color: Colors.white, fontSize: 12),
    );
    final healthText = "${currentHealth.round()}/${maxHealth.round()}";
    final textPainter = textPaint.toTextPainter(healthText);
    textPainter.layout();
    textPainter.paint(canvas, Offset((barWidth - textPainter.width) / 2, -textPainter.height - 5));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // 필요하다면 업데이트 로직, 여기서는 없음
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
  static const double ballRadius = 15.0;
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
        ..density = 3.0
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
class Arrow extends BodyComponent with HasGameRef<Forge2DGame>, ContactCallbacks {
  final Vector2 startPosition;
  final Vector2 direction;
  late SpriteComponent spriteComponent;
  final double speed;
  bool markedForRemoval = false;
  double _lifeTime = 0.0; // 화살의 생존 시간
  static const double lifeDuration = 7.0; // 화살이 사라지기까지의 시간 (초)
  final double damage; // 화살이 가하는 피해량


  Arrow(this.startPosition, this.direction, this.speed, this.damage);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final arrowSprite = await gameRef.loadSprite('arrow.png');
    spriteComponent = SpriteComponent(
      sprite: arrowSprite,
      size: Vector2(20, 10),
      anchor: Anchor.center,
    );
    add(spriteComponent);
  }

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBox(10, 2.5, Vector2.zero(), 0.0);
    final fixtureDef = FixtureDef(shape)
      ..density = 0.5
      ..friction = 0.2
      ..restitution = 0.0
      ..isSensor = true;

    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = startPosition;
    final arrowBody = world.createBody(bodyDef)..createFixture(fixtureDef);
    arrowBody.userData = this;

    arrowBody.linearVelocity = direction.normalized() * speed;

    return arrowBody;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (markedForRemoval) {
      world.destroyBody(body);
      removeFromParent();
      return;
    }

    body.linearVelocity = direction.normalized() * speed;
    spriteComponent.angle = direction.angleTo(Vector2(1,0));
    // 화살의 생존 시간을 추적하고, 지정된 시간이 지나면 제거
    _lifeTime += dt;
    if (_lifeTime >= lifeDuration) {
      markedForRemoval = true;
    }
  }
  @override
  void beginContact(Object other, Contact contact) {
    if (other is Player) {
      // 플레이어에게 피해를 입힘
      other.takeDamage(damage);

      // 화살을 제거
      markedForRemoval = true;

      // 효과음 재생 (선택 사항)
      FlameAudio.play('hit.mp3');
    }
  }
}



class Turret extends BodyComponent with HasGameRef<Forge2DGame> {
  final Vector2 position;
  Player? player; // 플레이어를 나중에 할당
  late SpriteComponent spriteComponent;
  double fireInterval = 3.0; // 한 번의 발사 간격 (초 단위)
  double ultFireInterval = 10.0; // 거대 화살 발사 간격 (초 단위)
  double _timeSinceLastFire = 0.0;
  double _timeSinceLastUltFire = 0.0; // 거대 화살을 위한 타이머

  // 연사 시 사용될 발사 간격 (초 단위)
  final double burstInterval = 0.15; // 각 화살 사이의 간격
  final int numberOfArrows = 3; // 한번의 발사당 화살 수
  bool _isChargingUlt = false;
  late CircleComponent _ultChargeEffect; // 붉은 색 기운을 표시할 컴포넌트

  Turret(this.position) {
    _ultChargeEffect = CircleComponent(
      radius: 50, // 터렛 크기보다 약간 큰 원으로 설정
      anchor: Anchor.center,
      paint: Paint()..color = Colors.red.withOpacity(0.5),
    );
  }

  /// 플레이어를 설정하는 메서드
  void setPlayer(Player p) {
    player = p;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await gameRef.loadSprite('turret.png');
    spriteComponent = SpriteComponent(
      sprite: sprite,
      size: Vector2(40, 40),
      anchor: Anchor.center,
    );
    add(spriteComponent);
    _ultChargeEffect.position = Vector2(0, 0); // 터렛의 중심에 위치
    add(_ultChargeEffect); // 터렛에 추가
    _ultChargeEffect.renderShape = false; // 기본적으로는 보이지 않게 설정
  }

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBox(20, 20, Vector2.zero(), 0.0);
    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..friction = 0.5
      ..restitution = 0.0
      ..isSensor = false;

    final bodyDef = BodyDef()
      ..type = BodyType.static
      ..position = position;

    final turretBody = world.createBody(bodyDef)..createFixture(fixtureDef);
    turretBody.userData = this;
    return turretBody;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (player == null) return; // 플레이어가 아직 할당 안 됐으면 발사하지 않음

    _timeSinceLastFire += dt;
    _timeSinceLastUltFire += dt;

    if (_timeSinceLastUltFire >= ultFireInterval - 0.8 && _timeSinceLastUltFire < ultFireInterval) {
      if (!_isChargingUlt) {
        _isChargingUlt = true;
        _ultChargeEffect.renderShape = true; // 궁극기 충전 효과 보이기
      }
    } else {
      if (_isChargingUlt) {
        _isChargingUlt = false;
        _ultChargeEffect.renderShape = false; // 충전 효과 숨기기
      }
    }
    if (_timeSinceLastFire >= fireInterval) {
      _timeSinceLastFire = 0;
      _fireArrowsBurst();
    }
    if (_timeSinceLastUltFire >= ultFireInterval) {
      _timeSinceLastUltFire = 0;
      _fireGiantArrow();
    }

    // 터렛이 플레이어를 향하도록 회전 (선택 사항)
    _rotateTowardsPlayer();
  }

  /// 여러 발의 화살을 연속적으로 발사하는 메서드
  void _fireArrowsBurst() {
    FlameAudio.play('shoot_3.mp3');

    for (int i = 0; i < numberOfArrows; i++) {
      // 각 화살 발사 시점에 burstInterval 만큼 지연을 추가
      Future.delayed(Duration(milliseconds: (burstInterval * 1000 * i).toInt()), () {
        _fireSingleArrow();

      });
    }
  }

  /// 단일 화살을 발사하는 메서드
  void _fireSingleArrow() {
    if (player == null) return;

    // 화살의 시작 위치를 터렛의 앞쪽으로 설정 (예: 현재 각도에 맞게 회전)
    Vector2 rotatedOffset = _getRotatedVector(Vector2(30, 0), spriteComponent.angle);
    final arrowStart = body.position + rotatedOffset;

    // 플레이어 위치를 향한 방향 계산
    final direction = (player!.body.position - arrowStart).normalized();

    // 화살 생성 및 게임에 추가
    final arrow = Arrow(arrowStart, direction, 80, 10);
    gameRef.add(arrow);
  }

  void _fireGiantArrow() {
    if (player == null) return;
    FlameAudio.play('pow.mp3');


    Vector2 rotatedOffset = _getRotatedVector(Vector2(30, 0), spriteComponent.angle);
    final arrowStart = body.position + rotatedOffset;
    final direction = (player!.body.position - arrowStart).normalized();

    final bigArrow = GiantArrow(arrowStart, direction, 120, 25); // 이거 최대 적용 속도가 120임.
    gameRef.add(bigArrow);
  }
  void _rotateTowardsPlayer() {
    if (player == null) return;

    // 터렛에서 플레이어로의 방향 벡터 계산
    Vector2 direction = player!.body.position - body.position;

    // atan2를 사용하여 라디안 단위로 각도 계산 (360도 회전을 위해)
    double angleInRadians = atan2(direction.y, direction.x);

    // 라디안을 도 단위로 변환 (스프라이트 회전이 도 단위를 기대하면)
    double angleInDegrees = angleInRadians * (180.0 / pi);

    // 각도가 음수일 경우 360도를 더해 양수로 만듦
    if (angleInDegrees < 0) {
      angleInDegrees += 360;
    }

    // 터렛 스프라이트의 회전 각도 설정
    spriteComponent.angle = angleInDegrees * (pi / 180.0); // 다시 라디안으로 변환
  }

  /// 주어진 벡터를 특정 각도로 회전시킨 새로운 벡터를 반환하는 메서드
  Vector2 _getRotatedVector(Vector2 vector, double angle) {
    // 벡터를 회전시키기 위해 삼각함수를 사용
    double cosTheta = cos(angle);
    double sinTheta = sin(angle);
    double x = vector.x * cosTheta - vector.y * sinTheta;
    double y = vector.x * sinTheta + vector.y * cosTheta;
    return Vector2(x, y);
  }
}

class GameOverComponent extends PositionComponent with HasGameRef<Forge2DGame> {
  final VoidCallback onRestart;

  GameOverComponent({required this.onRestart});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = gameRef.size / 2; // 화면 중앙에 배치
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 반투명 배경
    final rect = Rect.fromLTWH(-gameRef.size.x / 2, -gameRef.size.y / 2, gameRef.size.x, gameRef.size.y);
    final backgroundPaint = Paint()..color = const Color(0x88000000);
    canvas.drawRect(rect, backgroundPaint);

    // "Game Over" 텍스트
    final textPaint = TextPaint(
      style: const TextStyle(color: Colors.red, fontSize: 48, fontWeight: FontWeight.bold),
    );
    textPaint.render(canvas, 'Game Over', Vector2(-100, -50));

    // "Restart" 버튼
    final restartPaint = TextPaint(
      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
    );
    restartPaint.render(canvas, 'Press Load Button to restart', Vector2(-130, 20));
  }

  bool handleTapDown(TapDownDetails details) {
    onRestart();
    removeFromParent();
    return true;
  }
}

class GiantArrow extends Arrow {


  GiantArrow(Vector2 startPosition, Vector2 direction, double speed, double damage) : super(startPosition, direction, speed, damage) {
  }
  @override
  void update(double dt) {
    super.update(dt);
    if (markedForRemoval) {
      world.destroyBody(body);
      removeFromParent();
      return;
    }
    // GiantArrow의 속도를 적용
    body.linearVelocity = direction.normalized() * speed;
    spriteComponent.angle = direction.angleTo(Vector2(1,0));
  }


  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final arrowSprite = await gameRef.loadSprite('giant_arrow.png'); // 거대 화살의 이미지를 사용하세요
    print("GiantArrow speed set to: ${speed}");

    spriteComponent = SpriteComponent(
      sprite: arrowSprite,
      size: Vector2(60, 30), // 더 큰 크기
      anchor: Anchor.center,
    );
    add(spriteComponent);
  }

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBox(30, 7.5, Vector2.zero(), 0.0); // 더 큰 물리적 크기
    final fixtureDef = FixtureDef(shape)
      ..density = 1.0 // 밀도를 조정할 수 있음
      ..friction = 0.2
      ..restitution = 0.0
      ..isSensor = true;

    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = startPosition;
    final arrowBody = world.createBody(bodyDef)..createFixture(fixtureDef);
    arrowBody.userData = this;

    arrowBody.linearVelocity = direction.normalized() * speed;
    return arrowBody;
  }
}
