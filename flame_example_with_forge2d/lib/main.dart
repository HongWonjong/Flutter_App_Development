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
import 'object.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MountainClimberGame game = MountainClimberGame();
  String selectedStage = "Stage 1";
  final FocusNode gameFocusNode = FocusNode();

  void loadSelectedStage(String stage) {
    setState(() {
      if (stage == "Stage 1") {
        game.loadStage(Stage1(game.size));
      } else if (stage == "Stage 2") {
        game.loadStage(Stage2(game.size));
      } else if (stage == "Stage 3") {
        game.loadStage(Stage3(game.size));
      } else if (stage == "Stage 4") {
        game.loadStage(Stage4(game.size));
      } else if (stage == "Stage 5") {
        game.loadStage(Stage5(game.size));
      } else if (stage == "Stage 6") {
        game.loadStage(Stage6(game.size));
      } else if (stage == "Stage 7") {
        game.loadStage(Stage7(game.size));
      } else if (stage == "Stage 8") {
        game.loadStage(Stage8(game.size));
      } else if (stage == "Stage 9") {
        game.loadStage(Stage9(game.size));
      } else if (stage == "Stage 10") {
        game.loadStage(Stage10(game.size));
      }
    });

    // 게임 위젯에 포커스 설정
    gameFocusNode.requestFocus();
  }

  PointerDeviceKind? inputKind; // 입력 장치를 저장할 변수

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 6,
              child: RawKeyboardListener(
                focusNode: gameFocusNode,
                onKey: (RawKeyEvent event) {
                  if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
                    game.currentStage.player.jump();
                  }
                },
                child: Listener(
                  onPointerSignal: (PointerSignalEvent event) {
                    if (event is PointerScrollEvent) {
                      // 마우스 휠 입력 처리
                      game.currentStage.handleMouseScroll(event);
                    }
                  },
                  child: GestureDetector(
                    onPanStart: (details) {
                      // 입력 장치를 기록
                      inputKind = details.kind;
                    },
                    onPanUpdate: (details) {
                      if (inputKind == PointerDeviceKind.touch) {
                        // 스마트폰 터치 입력
                        game.currentStage.handlePanUpdate(details);
                      } else if (inputKind == PointerDeviceKind.mouse) {
                        // 컴퓨터 마우스 입력
                        game.currentStage.handleMouseScroll(PointerScrollEvent(
                          position: details.globalPosition,
                          scrollDelta: details.delta,
                        ));
                      }
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
                child: FocusScope(
                  canRequestFocus: false, // 드롭다운이 포커스를 가져가지 않게 설정
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<String>(
                        value: selectedStage,
                        items: [
                          DropdownMenuItem(value: "Stage 1", child: Text("Stage 1")),
                          DropdownMenuItem(value: "Stage 2", child: Text("Stage 2")),
                          DropdownMenuItem(value: "Stage 3", child: Text("Stage 3")),
                          DropdownMenuItem(value: "Stage 4", child: Text("Stage 4")),
                          DropdownMenuItem(value: "Stage 5", child: Text("Stage 5")),
                          DropdownMenuItem(value: "Stage 6", child: Text("Stage 6")),
                          DropdownMenuItem(value: "Stage 7", child: Text("Stage 7")),
                          DropdownMenuItem(value: "Stage 8", child: Text("Stage 8")),
                          DropdownMenuItem(value: "Stage 9", child: Text("Stage 9")),
                          DropdownMenuItem(value: "Stage 10", child: Text("Stage 10")),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedStage = value;
                            });
                          }
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          loadSelectedStage(selectedStage);
                        },
                        child: Text('Load Stage'),
                      ),
                    ],
                  ),
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
  void showGameOver() {

    // GameOverComponent 추가
    add(GameOverComponent(onRestart: () {
      // 현재 스테이지를 다시 로드
      loadStage(currentStage.runtimeType == Stage1
          ? Stage1(size)
          : currentStage.runtimeType == Stage2
          ? Stage2(size)
          : currentStage.runtimeType == Stage3
          ? Stage3(size)
          : currentStage.runtimeType == Stage4
          ? Stage4(size)
          : currentStage.runtimeType == Stage5
          ? Stage5(size)
          : currentStage.runtimeType == Stage6
          ? Stage6(size)
          : currentStage.runtimeType == Stage7
          ? Stage7(size)
          : currentStage.runtimeType == Stage8
          ? Stage8(size)
          : currentStage.runtimeType == Stage9
          ? Stage9(size)
          : Stage10(size));
    }));
  }
}





