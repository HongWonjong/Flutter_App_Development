import 'dart:math';
import 'rpg_game.dart';
import '../functions/monster_skill.dart';

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
  final List<Function(RpgGame, BossMonster)> bossSkills; // 보스는 여러 스킬을 쓸 수 있다.

  BossMonster(String name, int hp, int atk, int def, String description, int level, this.bossSkills)
      : super(name, hp, atk, def, description, level);
}