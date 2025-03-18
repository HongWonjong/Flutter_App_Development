import 'dart:math';
import 'rpg_game.dart';
import '../functions/monster_skill.dart';

class Monster {
  final String name;
  final int hp;
  final int atk;
  final int def;
  final String description;
  final int level; // 몬스터의 레벨은 대체적인 강함을 알려줄 뿐 아니라, 어떤 구간의 스테이지에서 출현할지를 정하는 중요한 변수다.
  final Function(RpgGame, Monster)? skill; // 스킬을 쓸 수 있다.
  bool skill_used; // 광폭화나 껍질 숨기 같은 일회성 스킬의 경우는 한 번만 발동 가능하게 해야 한다.


  Monster(this.name, this.hp, this.atk, this.def, this.description, this.level,
      {this.skill, this.skill_used = false});
}


class BossMonster extends Monster {
  final List<Function(RpgGame, BossMonster)> bossSkills; // 보스는 여러 스킬을 쓸 수 있으므로 리스트의 형태로 스킬을 저장한다.

  BossMonster(String name, int hp, int atk, int def, String description, int level, this.bossSkills)
      : super(name, hp, atk, def, description, level);
}