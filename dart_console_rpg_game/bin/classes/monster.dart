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


void berserk(RpgGame game, Monster monster) {
  print("${monster.name}가 광폭화했습니다! 공격력이 ${monster.atk + 20}으로 증가했습니다.");
  monster.skill_used = true;
}

void hardenedClaws(RpgGame game, Monster monster) {
  int extraDamage = (game.total_def / 2).floor();
  int totalDamage = monster.atk + extraDamage;
  print("${monster.name}가 발톱을 순간적으로 경화해서 방어구를 꿰뚫는 공격을 날립니다 , 총 피해: $totalDamage");
  game.hp_now -= totalDamage.clamp(0, totalDamage);
}


void indescribableGaze(RpgGame game, BossMonster boss) {
  int reducedAtk = (game.total_atk * 0.7).floor();
  int reducedDef = (game.total_def * 0.7).floor();
  game.buff_atk = reducedAtk - game.base_atk - game.item_atk;
  game.buff_def = reducedDef - game.base_def - game.item_def;
  print("${boss.name}의 형언할 수 없는 공포의 응시! 당신의 공격력이 $reducedAtk, 방어력이 $reducedDef로 줄어들었습니다!");
}

void tentaclePush(RpgGame game, BossMonster boss) async {
  Random random = Random();
  int hits = 3 + random.nextInt(3);
  int totalDamage = 0;
  for (int i = 0; i < hits; i++) {
    int baseDamage = (boss.atk * (1 + i * 0.2)).toInt(); // 기본 데미지
    int damage = (baseDamage - (game.total_def / 2).floor()).clamp(0, baseDamage); // 방어력의 절반만 반영
    totalDamage += damage;
    game.hp_now -= damage;
    print("${boss.name}의 촉수가 갑옷을 꿰뚫는 날카로운 창으로 변해 당신을 밀칩니다! $damage 데미지!");
    await Future.delayed(Duration(seconds: 1));
  }
  print("${boss.name}의 촉수 공격! $hits번 맞았다! 총 데미지: $totalDamage");
}

final List<Monster> monsterList = [
  Monster("슬라임", 20, 5, 2, "끈적거리는 작은 괴물이다.", 1),
  Monster("고블린", 30, 8, 4, "작고 교활한 도둑이다.", 3),
  Monster("웨어울프", 50, 15, 8, "달빛 아래 포효하는 야수다.", 5, skill: hardenedClaws),
  Monster("미노타우르스", 80, 20, 12, "거대한 뿔을 가진 괴수다.", 7, skill: berserk),
];


final List<BossMonster> bossList = [
  BossMonster(
    "외신 크툴루",
    200,
    25,
    15,
    "형언할 수 없는 존재감이 느껴지는 고대의 신이다.",
    11,
    [indescribableGaze, tentaclePush],
  ),
];