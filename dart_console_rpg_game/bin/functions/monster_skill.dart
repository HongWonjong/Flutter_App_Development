import '../classes/rpg_game.dart';
import '../classes/monster.dart';
import 'dart:math';

// berserk는 미노타우르스의 체력이 절반 미만으로 떨어지는 순간 발동된다. 패시브이므로 직후 공격이 가능하다.
void berserk(RpgGame game, Monster monster) {
  print("${monster.name}가 광폭화했습니다! 공격력이 ${monster.atk + 20}으로 증가하고 방어력이 ${monster.def + 10} 증가합니다.");
  monster.skill_used = true;
} // 몬스터의 공/방 처럼 final로 선언된 것들은 인스턴스 자체의 값을 바꿀 수 없으므로 원래 값을 별도의 변수로 복사하여 사용한다.

// hardenedClaws 는 웨어울프의 특수 전용기로, 플레이어의 방어력의 절반 만큼을 자신의 이번 공격에 합산하여 공격한다. 맞으면 아프다.
void hardenedClaws(RpgGame game, Monster monster) {
  int extraDamage = (game.player.totalDef ~/ 2);
  int baseDamage = monster.atk + extraDamage;
  int totalDamage = (baseDamage - game.player.totalDef).clamp(0, baseDamage); //방어력 계산 시, 음수가 되거나 하지 않게 제한을 둔다.
  print("${monster.name}가 발톱을 순간적으로 경화해서 방어구를 꿰뚫는 공격을 날립니다, 총 피해: $totalDamage");
  game.player.hpNow -= totalDamage;
}

// 트롤은 매 턴 시작 시 HP를 20 회복한다.
void regenerate(RpgGame game, Monster monster) {
  int healAmount = 20;
  print("${monster.name}의 상처가 빠르게 재생됩니다! HP가 $healAmount 회복되었습니다.");
  // 마찬가지로 HP 회복은 dungeon 메서드에서 직접 처리해야 한다(monster.hp는 final이므로)
}

// 마법사 유령은 공격력의 1.5배 데미지의 파이어볼을 날릴 수 있다.
void fireball(RpgGame game, Monster monster) {
  int baseDamage = (monster.atk * 1.5).toInt();
  int totalDamage = (baseDamage - game.player.totalDef).clamp(0, baseDamage);
  print("${monster.name}가 불타는 파이어볼을 날립니다! $totalDamage 데미지!");
  game.player.hpNow -= totalDamage;
}

// 살인거북이는 전투 시작 시 무조건 방어력 15 증가하는 껍질 숨기 기술을 쓰고 시작한다.
void shellHide(RpgGame game, Monster monster) {
  print("${monster.name}가 등껍질에 숨었습니다! 방어력이 15 증가합니다.");
  monster.skill_used = true; // 시작 시 한 번만 발동하도록
}

// 거대 전갈은 스킬 사용 시 플레이어 방어력만큼 데미지 추가
void tailSting(RpgGame game, Monster monster) {
  int extraDamage = game.player.totalDef;
  int baseDamage = monster.atk + extraDamage;
  int totalDamage = (baseDamage - game.player.totalDef).clamp(0, baseDamage);
  print("${monster.name}가 독침으로 찔렀습니다! 플레이어 방어력을 뚫고 $totalDamage 데미지!");
  game.player.hpNow -= totalDamage;
}


// 크툴루의 디버프 공격이다. 공격과 방어를 70% 수준으로 낮춘다. 플레이어는 광분과 방패 올리기 스킬로 디버프를 견뎌낼 수 있다.
void indescribableGaze(RpgGame game, BossMonster boss) {
  int reducedAtk = (game.player.totalAtk * 0.7).floor(); // Player의 totalAtk 사용
  int reducedDef = (game.player.totalDef * 0.7).floor(); // Player의 totalDef 사용
  game.player.buffAtk = reducedAtk - game.player.baseAtk - game.player.itemAtk;
  game.player.buffDef = reducedDef - game.player.baseDef - game.player.itemDef;
  print("${boss.name}의 형언할 수 없는 공포의 응시! 당신의 공격력이 $reducedAtk, 방어력이 $reducedDef로 줄어들었습니다!");
}

// 크툴루는 일반 공격도 그냥 스킬에 넣었다. 그냥 좀 쎄게 팰 뿐..
void justAttack(RpgGame game, BossMonster boss) {
  Random random = Random();
  int atkMultiple = random.nextInt(50) + 100;
  int baseDamage = boss.atk * atkMultiple ~/ 100;
  int totalDamage = (baseDamage - game.player.totalDef).clamp(0, baseDamage);
  print("${boss.name}의 일격! $totalDamage 데미지!");
  game.player.hpNow -= totalDamage;
}

// 크툴루의 다단 히트 공격이다. 3~5번 타격하고, 연타가 이어질수록 아프다.
void tentaclePush(RpgGame game, BossMonster boss) async {
  Random random = Random();
  int hits = 3 + random.nextInt(3); // 3~5회 타격
  int totalDamage = 0;
  for (int i = 0; i < hits; i++) {
    int baseDamage = (boss.atk * (1 + i * 0.2)).toInt(); // 다단히트 강화
    // 매 다단히트 계산 시 Player의 totalDef이 반영은 되지만, 절반만 반영되므로 아프게 맞는다.
    int damage = (baseDamage - (game.player.totalDef ~/ 2)).clamp(0, baseDamage);
    totalDamage += damage;
    game.player.hpNow -= damage; // Player의 hpNow 감소
    print("${boss.name}의 촉수가 갑옷을 꿰뚫는 날카로운 창으로 변해 당신을 밀칩니다! $damage 데미지!");
    await Future.delayed(Duration(seconds: 1));
  }
  print("${boss.name}의 촉수 공격! $hits번 맞았다! 총 데미지: $totalDamage");
}
