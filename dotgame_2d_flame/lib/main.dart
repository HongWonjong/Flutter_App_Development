// lib/main.dart

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'tile_sprites.dart';
import 'map_data.dart';
import 'tile_defs.dart';

class MyDotGame extends FlameGame {
  late TileSprites tileSprites;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 전체화면 및 가로화면 설정 (옵션)
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();

    // TileSprites 인스턴스 생성 및 스프라이트 로드
    tileSprites = TileSprites(this);
    await tileSprites.loadAllSprites();

    // 타일맵 컴포넌트 생성 및 추가
    final tileMap = TileMapComponent(
      mapData: myMap,          // map_data.dart에 정의된 2D 배열
      tileSprites: tileSprites,
      tileSize: 32.0,
    );
    add(tileMap);

    // TODO: 플레이어, 적, 카메라 등 추가 가능
  }
}

// 타일맵을 그려주는 컴포넌트
class TileMapComponent extends Component {
  final List<List<int>> mapData;
  final TileSprites tileSprites;
  final double tileSize;

  TileMapComponent({
    required this.mapData,
    required this.tileSprites,
    this.tileSize = 32.0,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final rows = mapData.length;
    final cols = mapData[0].length;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final tileIndex = mapData[row][col];
        final spriteComponent = SpriteComponent()
          ..position = Vector2(col * tileSize, row * tileSize)
          ..size = Vector2(tileSize, tileSize);

        switch (tileIndex) {
          case SKY:
            spriteComponent.sprite = tileSprites.sky;
            break;

          case CLOUD_LEFT:
            spriteComponent.sprite = tileSprites.cloudLeft;
            spriteComponent.scale.x = 1;
            spriteComponent.anchor = Anchor.topLeft;
            break;

          case CLOUD_RIGHT:
          // 왼쪽 구름 이미지를 반전해서 오른쪽 구름처럼 표현
            spriteComponent.sprite = tileSprites.cloudLeft;
            spriteComponent.scale.x = -1;
            spriteComponent.anchor = Anchor.topRight;
            break;

          case GROUND_SURFACE:
            spriteComponent.sprite = tileSprites.groundSurface;
            break;

          case GROUND:
            spriteComponent.sprite = tileSprites.ground;
            break;

          case BOX:
            spriteComponent.sprite = tileSprites.box;
            break;

          case QUESTION_BOX:
            spriteComponent.sprite = tileSprites.questionBox;
            break;

          default:
          // 기본값: SKY
            spriteComponent.sprite = tileSprites.sky;
        }

        add(spriteComponent);
      }
    }
  }
}

// 메인 함수
void main() {
  runApp(
    GameWidget(
      game: MyDotGame(),
    ),
  );
}
