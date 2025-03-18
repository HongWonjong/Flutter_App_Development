import 'item.dart';

class Merchants {
  final List<Item> merchants_item = [
    Item("카타나", false, 50, true, 1, atk: 10, "3자루를 들어서 해적 사냥꾼이 되어보자."),
    Item("나무_방패", false, 30, true, 1, def: 10, "나무 방패를 쓰면 \\\"방패 들기\\\" 이라는 스킬을 쓸 수 있다."),
    Item("빨간_포션", true, 10, false, 1, hp: 50, "제픔 설명: 타우린, 고농축 카페인, 합성 착향 색소, 아르기닌 500mg 포함"),
    Item("파란_포션", true, 15, false, 1, mp: 50, "제픔 설명: 비타민 A, B, C, D, ....Z 등이 포함되어 있습니다."),
    Item("선두", true, 50, false, 1, hp:100, mp:100, "누군가에 의하면, 한 알만 먹어도 열흘은 배부르다."),
    Item("햄부기", true, 20, false, 1, hp_increase: 10, "햄부기를 먹고 체급이 올라가면 곧 최대 hp가 올라가는 것입니다."),
    Item("마법가루", true, 20, false, 1, mp_increase: 10, "국경지대로부터 밀반입되는 이 가루는 최대 mp와 기분을 올려줍니다."),
    Item("엔딩만 보고 싶은 하남자를 위한 당근칼", false, 10, true, 1, "게임 구경만 하고 싶은 아기 플레이어를 위한 장난감입니다.", atk: 100, def: 100)

  ];

   Merchants();
}