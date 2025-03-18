import '../classes/monster.dart';
import '../functions/monster_skill.dart';

final List<Monster> monsterList = [ // 원래 과제에서는 csv에 저장해서 불러오라고 했지만 난 이렇게 만들고 싶군.
  Monster("슬라임", 20, 11, 2, "끈적끈적하다.", 1),
  Monster("고블린", 40, 13, 4, "약하다.", 2),
  Monster("웨어울프", 70, 15, 8, "갑옷을 부수는 경화된 발톱으로 공격을 하는 괴수다.", 4, skill: hardenedClaws),
  Monster("오크 전사", 100, 18, 10, "'야 저기 니 남자친구 지나간다 ㅋㅋ' 이라고 말 하려면 큰 용기가 필요하다.", 6),
  Monster("트롤", 120, 22, 14, "재생 능력이 뛰어난 거대한 괴물이다.", 7, skill: regenerate),
  Monster("미노타우르스", 150, 20, 12, "분노 할수록 강해지는 괴물이다.", 8, skill: berserk),
  Monster("살인거북이", 120, 20, 16, "등껍질에 숨으면 단단해진다.", 9, skill: shellHide),
  Monster("마법사 유령", 100, 25, 8, "파이어볼을 연습하다가 죽었고, 죽고 나서야 깨우쳤다.", 10, skill: fireball),
  Monster("거대 전갈", 150, 23, 15, "갑옷을 꿰뚫는 날카로운 독침으로 공격한다.", 12, skill: tailSting),
];

final List<BossMonster> bossList = [
  BossMonster(
    "외신 크툴루",
    250,
    30,
    20,
    "형언할 수 없는 존재감이 느껴지는 고대의 신이다. 눈을 마주칠 수 없다.",
    11,
    [indescribableGaze, tentaclePush, justAttack],
  ),
];