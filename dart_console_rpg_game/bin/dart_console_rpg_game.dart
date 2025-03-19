import 'classes/rpg_game.dart';


void main(List<String> arguments) {
  RpgGame rpgGame = RpgGame("춘식이");
  print("나만의 콘솔 어드벤쳐에 오신 것을 환영합니다! 갈수록 어려워지는 던전을 답파하고 돈을 모아 마을에서 더 강해지세요! 강력한 보스도 있습니다.");
  rpgGame.run();
}
