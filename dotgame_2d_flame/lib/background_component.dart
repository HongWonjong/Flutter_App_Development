// lib/background_component.dart

import 'package:flame/components.dart';
import 'package:flame/game.dart';

class BackgroundComponent extends SpriteComponent with HasGameRef<FlameGame> {
  BackgroundComponent({
    required Sprite sprite,
    required Vector2 size,
  }) : super(sprite: sprite, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 화면 크기에 맞게 배경 이미지 크기 조정
    size = gameRef.size;
    position = Vector2.zero();
    anchor = Anchor.topLeft;
  }
}
