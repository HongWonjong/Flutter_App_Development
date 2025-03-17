class Monster {
  final String name;
  final int hp;
  final int atk;
  final int def;
  final String description;
  final int level;

  Monster(this.name, this.hp, this.atk, this.def, this.description, this.level);
}

// 몬스터 정의
final List<Monster> monsterList = [
  Monster("슬라임", 20, 10, 2, "끈적하다.", 1),
  Monster("고블린", 30, 15, 4, "교활하다", 3),
  Monster("웨어울프", 50, 20, 8, "좀 무섭다.", 5),
  Monster("미노타우르스", 80, 25, 12, "진짜 무섭다.", 7),
];