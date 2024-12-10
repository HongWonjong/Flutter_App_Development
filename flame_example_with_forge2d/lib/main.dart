import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';



void main() {
  final game = MountainClimberGame();

  runApp(
    RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
          game.player.jump();
        }
      },
      child: Listener(
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
    ),
  );
}

class MountainClimberGame extends Forge2DGame {
  MountainClimberGame() : super(gravity: Vector2(0, 200), zoom: 10.0) {
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

    player = Player();
    add(player);
    await player.loaded;

    final ballAndChain = BallAndChain(player);
    add(ballAndChain);

    final platforms = [
      Vector2(300, 100),
      Vector2(500, 250),
      Vector2(400, 300),
      Vector2(200, 200),
    ];
    for (final position in platforms) {
      add(FloatingPlatform(position, Vector2(100, 20)));
    }

    final destructibleBoxes = [
      Vector2(600, 300),
      Vector2(700, 400),
      Vector2(200, 100),
    ];

    for (final position in destructibleBoxes) {
      add(DestructibleBox(position: position, size: Vector2(50, 50)));
    }

    final boundaries = createBoundaries();
    for (final boundary in boundaries) {
      add(boundary);
    }
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      player.jump();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
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
    if (event.scrollDelta.dy > 0) {
      player.rotatePlayer(rotateSpeed);
    } else if (event.scrollDelta.dy < 0) {
      player.rotatePlayer(-rotateSpeed);
    }
  }

  void handlePanUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 0) {
      player.rotatePlayer(rotateSpeed);
    } else if (details.delta.dx < 0) {
      player.rotatePlayer(-rotateSpeed);
    }
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
  @override
  final Paint paint = Paint()..color = const Color(0xFFA0522D);

  @override
  Body createBody() {
    final gameSize = game.size;
    final shape = PolygonShape()..setAsBoxXY(gameSize.x, gameSize.y * 0.05);
    final fixtureDef = FixtureDef(shape)
      ..friction = 0.9
      ..restitution = 0.0
      ..isSensor = false;
    final bodyDef = BodyDef()
      ..type = BodyType.static
      ..position = Vector2(0, gameSize.y);
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
      ..density = 1.0
      ..friction = 0.6
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
    // 기존의 박스 렌더링을 먼저 수행
    super.render(canvas);

    final pos = body.position;

    // 체력바 그리기
    canvas.save();
    canvas.translate(size.x - 50, size.y / 2 - 25);

    final barWidth = size.x;
    final barHeight = 5.0;
    final barOffsetY = -size.y/2 - 10;
    final healthRatio = currentHealth / maxHealth;
    final currentBarWidth = barWidth * healthRatio;

    final healthBarPaint = Paint()..color = Colors.green;
    canvas.drawRect(
      Rect.fromLTWH(-barWidth/2, barOffsetY, currentBarWidth, barHeight),
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
      _renderCracks(canvas);
    }

    canvas.restore();
  }

  void _renderCracks(Canvas canvas) {
    final crackPath = Path()
      ..moveTo(-size.x / 4, -size.y / 4)
      ..lineTo(size.x / 4, 0)
      ..lineTo(-size.x / 4, size.y / 4);
    canvas.drawPath(crackPath, crackPaint);
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
        final damage = maxImpulse / 20000;
        currentHealth -= damage;
        print('Box damaged by ball: $damage, Current Health: $currentHealth');
        if (currentHealth <= 0) {
          _markedForDestruction = true;
        }
      }
    }
  }
}



class Mountain extends BodyComponent {
  @override
  final Paint paint = Paint()..color = const Color(0xFF228B22);

  @override
  Body createBody() {
    final gameSize = game.size;
    final mountainVertices = [
      Vector2(-gameSize.x * 0.5, 0),
      Vector2(-gameSize.x * 0.3, -gameSize.y * 0.2),
      Vector2(-gameSize.x * 0.2, -gameSize.y * 0.1),
      Vector2(0, -gameSize.y * 0.3),
      Vector2(gameSize.x * 0.2, -gameSize.y * 0.15),
      Vector2(gameSize.x * 0.3, -gameSize.y * 0.25),
      Vector2(gameSize.x * 0.5, 0),
    ];
    final shape = PolygonShape()..set(mountainVertices);
    final fixtureDef = FixtureDef(shape)
      ..friction = 0.9
      ..restitution = 0.0
      ..isSensor = false;
    final bodyDef = BodyDef()
      ..type = BodyType.static
      ..position = Vector2(gameSize.x / 2, gameSize.y - (gameSize.y * 0.05));
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Player extends GravityBodyComponent with ContactCallbacks {
  @override
  final Paint paint = Paint()..color = const Color(0xFFFFA500);

  @override
  Body createBody() {
    final gameSize = game.size;
    final shape = CircleShape()..radius = 15;
    final fixtureDef = FixtureDef(shape)
      ..density = 4.0
      ..friction = 0.9
      ..restitution = 0.0;
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = Vector2(gameSize.x / 4, gameSize.y / 2);
    final playerBody = world.createBody(bodyDef)..createFixture(fixtureDef);
    playerBody.userData = this;
    return playerBody;
  }

  void jump() {
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
    await Future.delayed(Duration.zero);
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
          ..density = 2.0
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
        ..density = 2.0
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





