// lib/tile_sprites.dart

import 'package:flame/game.dart';
import 'package:flame/components.dart';

class TileSprites {
  final FlameGame game;

  late final Sprite sky;
  late final Sprite cloudLeft;
  late final Sprite groundSurface;
  late final Sprite ground;
  late final Sprite box;
  late final Sprite questionBox;
  late final SpriteAnimation playerIdle;
  late final SpriteAnimation playerRun;

  TileSprites(this.game);

  Future<void> loadAllSprites() async {
    sky = await game.loadSprite('sky.png');
    cloudLeft = await game.loadSprite('cloud_left.png');
    groundSurface = await game.loadSprite('ground_surface.png');
    ground = await game.loadSprite('ground.png');
    box = await game.loadSprite('box.png');
    questionBox = await game.loadSprite('question_box.png');
  }

  Future<Map<String, SpriteAnimation>> loadPlayerAnimations() async {
    final spriteSheet = await game.images.load('player_spritesheet.png');
    playerIdle = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(amount: 4, textureSize: Vector2(32, 32), stepTime: 0.1),
    );
    playerRun = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(amount: 4, textureSize: Vector2(32, 32), stepTime: 0.1),
    );
    return {'idle': playerIdle, 'run': playerRun};
  }
}
