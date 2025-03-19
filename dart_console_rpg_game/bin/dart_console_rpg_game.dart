import 'dart:io';

import 'classes/rpg_game.dart';


void main(List<String> arguments) async{
  print("나만의 콘솔 어드벤쳐에 오신 것을 환영합니다! 갈수록 어려워지는 던전을 답파하고 돈을 모아 마을에서 더 강해지세요! 강력한 보스도 있습니다.");
  await Future.delayed(Duration(seconds: 1));
  print("사용하실 플레이어의 이름을 입력 해 주세요.");
  while (true) {
    String? playerName = stdin.readLineSync(); // null 가능성 처리
    if (playerName != null && playerName.isNotEmpty) { // 입력 안한 경우
      // 이름 유효성 검사를 정규식으로 실시한다. 한글, 영어 소문자, 영어 대문자만 허용
      if (RegExp(r'^[가-힣a-zA-Z]+$').hasMatch(playerName)) {
        RpgGame rpgGame = RpgGame(playerName);
        rpgGame.run();
        return; // 유효한 이름이면 게임 시작 후 종료
      } else {
        print("$playerName은 적합한 이름이 아닙니다. 한글 또는 영문 대소문자만 가능하고, 포함특수문자나 숫자는 허용되지 않습니다. 다시 시도하세요.");
      }
    } else {
      print("이름은 빈 문자열일 수 없습니다. 다시 시도하세요.");
    }
  }
}
