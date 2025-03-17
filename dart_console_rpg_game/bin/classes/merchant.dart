import 'item.dart';

class Merchants {
  final List<Item> merchants_item = [
    Item("카타나", false, 50, true, 1, atk: 10, "3자루를 들어서 해적 사냥꾼이 되어보자."),
    Item("나무_방패", false, 30, true, 1, def: 10, "나무 방패를 쓰면 \\\"방패 들기\\\" 이라는 스킬을 쓸 수 있다."),
    Item("빨간_포션", true, 10, false, 1, hp: 50, "제픔 설명: 타우린, 고농축 카페인, 합성 착향 색소, 아르기닌 500mg 포함"),
    Item("파란_포션", true, 15, false, 1, mp: 50, "제픔 설명: 비타민 A, B, C, D, ....Z 등이 포함되어 있습니다."),
    Item("선두", true, 50, false, 1, hp:100, mp:100, "이거 한 알이면 10일은 배가 부르다"),
    Item("햄부기", true, 5, false, 1, "햄부기햄북 햄북어 햄북스딱스 함부르크햄부가우가 햄비기햄부거 햄부가티햄부기온앤 온을 차려오거라.")

  ];

   Merchants();
}