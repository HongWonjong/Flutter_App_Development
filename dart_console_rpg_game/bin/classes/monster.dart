import 'dart:math';
import 'rpg_game.dart';

class Monster {
  final String name;
  final int hp;
  final int atk;
  final int def;
  final String description;
  final int level;
  final Function(RpgGame, Monster)? skill;
  bool skill_used;

  Monster(this.name, this.hp, this.atk, this.def, this.description, this.level,
      {this.skill, this.skill_used = false});
}

class BossMonster extends Monster {
  final List<Function(RpgGame, BossMonster)> bossSkills;

  BossMonster(String name, int hp, int atk, int def, String description, int level, this.bossSkills)
      : super(name, hp, atk, def, description, level);
}

// 몬스터 스킬: berserk
void berserk(RpgGame game, Monster monster) {
  print("${monster.name}가 광폭화했습니다! 공격력이 ${monster.atk + 20}으로 증가하고 방어력이 ${monster.def + 10} 증가합니다.");
  monster.skill_used = true;
}

// 몬스터 스킬: hardenedClaws
void hardenedClaws(RpgGame game, Monster monster) {
  int extraDamage = (game.player.totalDef ~/ 2); // Player의 totalDef 사용
  int totalDamage = monster.atk + extraDamage;
  print("${monster.name}가 발톱을 순간적으로 경화해서 방어구를 꿰뚫는 공격을 날립니다, 총 피해: $totalDamage");
  game.player.hpNow -= totalDamage.clamp(0, totalDamage); // Player의 hpNow 감소
}

// 보스 스킬: indescribableGaze
void indescribableGaze(RpgGame game, BossMonster boss) {
  int reducedAtk = (game.player.totalAtk * 0.7).floor(); // Player의 totalAtk 사용
  int reducedDef = (game.player.totalDef * 0.7).floor(); // Player의 totalDef 사용
  game.player.buffAtk = reducedAtk - game.player.baseAtk - game.player.itemAtk;
  game.player.buffDef = reducedDef - game.player.baseDef - game.player.itemDef;
  print("${boss.name}의 형언할 수 없는 공포의 응시! 당신의 공격력이 $reducedAtk, 방어력이 $reducedDef로 줄어들었습니다!");
}

// 보스 스킬: justAttack
void justAttack(RpgGame game, BossMonster boss) {
  Random random = Random();
  int atkMultiple = random.nextInt(50) + 100; // 1배 ~ 1.5배
  int damage = boss.atk * atkMultiple ~/ 100;
  game.player.hpNow -= damage; // Player의 hpNow 감소
  print("${boss.name}의 일격! $damage 데미지!");
}

// 보스 스킬: tentaclePush
void tentaclePush(RpgGame game, BossMonster boss) async {
  Random random = Random();
  int hits = 3 + random.nextInt(3); // 3~5회 타격
  int totalDamage = 0;
  for (int i = 0; i < hits; i++) {
    int baseDamage = (boss.atk * (1 + i * 0.2)).toInt(); // 다단히트 강화
    int damage = (baseDamage - (game.player.totalDef ~/ 2)).clamp(0, baseDamage); // Player의 totalDef 사용
    totalDamage += damage;
    game.player.hpNow -= damage; // Player의 hpNow 감소
    print("${boss.name}의 촉수가 갑옷을 꿰뚫는 날카로운 창으로 변해 당신을 밀칩니다! $damage 데미지!");
    await Future.delayed(Duration(seconds: 1));
  }
  print("${boss.name}의 촉수 공격! $hits번 맞았다! 총 데미지: $totalDamage");
}

final List<Monster> monsterList = [
  Monster("슬라임", 20, 11, 2, "끈적끈적하다.", 1),
  Monster("고블린", 40, 13, 4, "약하다.", 3),
  Monster("웨어울프", 70, 15, 8, "갑옷을 부수는 경화된 발톱으로 공격을 하는 괴수다.", 5, skill: hardenedClaws),
  Monster("미노타우르스", 100, 20, 12, "분노 할수록 강해지는 괴물이다.", 8, skill: berserk),
];

final List<BossMonster> bossList = [
  BossMonster(
    "외신 크툴루",
    250,
    25,
    15,
    "형언할 수 없는 존재감이 느껴지는 고대의 신이다. 눈을 마주칠 수 없다.",
    11,
    [indescribableGaze, tentaclePush, justAttack],
  ),
];