import 'item.dart';
import 'skill.dart';

class Player {
  int hpNow;
  int hpMax;
  int mpNow;
  int mpMax;
  int baseAtk;
  int baseDef;
  int buffAtk = 0;
  int buffDef = 0;
  int itemAtk = 0;
  int itemDef = 0;

  List<Item> inventory;
  List<Item> equippedItems;
  List<Skill> skills;

  Player({
    this.hpNow = 100,
    this.hpMax = 100,
    this.mpNow = 100,
    this.mpMax = 100,
    this.baseAtk = 10,
    this.baseDef = 10,
    required this.inventory,
    required this.equippedItems,
    required this.skills,
  });

  int get totalAtk => baseAtk + buffAtk + itemAtk;
  int get totalDef => baseDef + buffDef + itemDef;


  void useSkill(Skill skill) {
    if (mpNow < skill.skill_mp_cost) {
      print("MP가 부족합니다.");
      return;
    }
    if (skill.skill_name == "방패 올리기") {
      if (!inventory.any((item) => item.name == "나무_방패") && !equippedItems.any((item) => item.name == "나무_방패")) {
        print("나무 방패가 없어 방패 올리기 스킬을 사용할 수 없습니다.");
        return;
      }
      mpNow -= skill.skill_mp_cost;
      buffDef = skill.skill_damage_calculation.toInt();
      print("${skill.skill_name} 사용! 방어력이 $totalDef로 증가했습니다.");
    } else if (skill.skill_name == "광분") {
      mpNow -= skill.skill_mp_cost;
      buffAtk = skill.skill_damage_calculation.toInt();
      print("${skill.skill_name} 사용! 공격력이 $totalAtk로 증가했습니다.");
    } else if (skill.is_attack) {
      mpNow -= skill.skill_mp_cost;
      int damage = (totalAtk * skill.skill_damage_calculation).toInt();
      print("${skill.skill_name} 사용! 데미지: $damage");
    } else if (skill.is_heal) {
      mpNow -= skill.skill_mp_cost;
      hpNow = (hpNow + skill.skill_damage_calculation).clamp(0, hpMax).toInt();
      print("${skill.skill_name} 사용! HP가 $hpNow로 회복되었습니다.");
    }
  }

  void useItem(String itemName) {
    Item? item = inventory.firstWhere(
          (item) => item.name == itemName && item.isConsumable && item.quantity > 0,
      orElse: () => Item("", false, 0, false, 0, ""),
    );

    if (item.name.isEmpty) {
      print("해당 이름의 소비 가능한 아이템이 없거나 수량이 부족합니다.");
      return;
    }

    if (item.hp > 0) {
      hpNow = (hpNow + item.hp).clamp(0, hpMax).toInt();
      print("${item.name}을 사용했습니다! HP가 $hpNow로 회복되었습니다.");
    }
    if (item.mp > 0) {
      mpNow = (mpNow + item.mp).clamp(0, mpMax).toInt();
      print("${item.name}을 사용했습니다! MP가 $mpNow로 회복되었습니다.");
    }
    if (item.atk > 0 || item.def > 0) {
      buffAtk += item.atk;
      buffDef += item.def;
      print("${item.name}을 사용했습니다! 공격력: $totalAtk, 방어력: $totalDef");
    }
    if (item.hp_increase > 0) {
      hpMax += item.hp_increase;
      print("${item.name}을 사용했습니다! 최대 HP: $hpMax");
    }
    if (item.mp_increase > 0) {
      mpMax += item.mp_increase;
      print("${item.name}을 사용했습니다! 최대 MP: $mpMax");
    }

    item.quantity -= 1;
    if (item.quantity == 0 && item.name != "gold") {
      inventory.remove(item);
    }
  }

  void equipItem(String itemName, int equipCount) {
    Item? item = inventory.firstWhere(
          (item) => item.name == itemName && item.wearable && item.quantity > 0,
      orElse: () => Item("", false, 0, false, 0, ""),
    );

    if (item.name.isEmpty) {
      print("해당 이름의 장착 가능한 아이템이 없거나 수량이 부족합니다.");
      return;
    }

    if (equipCount <= 0 || equipCount > item.quantity) {
      print("장착할 수 있는 개수가 유효하지 않습니다. (보유: ${item.quantity})");
      return;
    }

    Item equipped = Item(item.name, item.isConsumable, item.price, item.wearable, equipCount, item.description,
        hp: item.hp, mp: item.mp, atk: item.atk, def: item.def);
    item.quantity -= equipCount;

    Item? existingEquipped = equippedItems.firstWhere(
          (e) => e.name == itemName,
      orElse: () => Item("", false, 0, false, 0, ""),
    );
    if (existingEquipped.name.isEmpty) {
      equippedItems.add(equipped);
    } else {
      existingEquipped.quantity += equipCount;
    }

    itemAtk += item.atk * equipCount;
    itemDef += item.def * equipCount;
    print("$itemName $equipCount개를 장착했습니다. 공격력: $totalAtk, 방어력: $totalDef");

    if (item.quantity == 0 && item.name != "gold") {
      inventory.remove(item);
    }
  }

  void unequipItem(String itemName, int unequipCount) {
    List<Item> toUnequip = equippedItems.where((item) => item.name == itemName).toList();
    if (toUnequip.isEmpty) {
      print("$itemName은 장착 중이 아닙니다.");
      return;
    }

    int totalEquippedCount = toUnequip.fold(0, (sum, item) => sum + item.quantity);
    if (unequipCount <= 0 || unequipCount > totalEquippedCount) {
      print("해제할 수 있는 개수가 유효하지 않습니다. (장착 중: $totalEquippedCount)");
      return;
    }

    int remaining = unequipCount;
    for (var equipped in toUnequip.toList()) {
      if (remaining <= 0) break;

      int countToRemove = remaining > equipped.quantity ? equipped.quantity : remaining;
      equipped.quantity -= countToRemove;
      remaining -= countToRemove;

      itemAtk -= equipped.atk * countToRemove;
      itemDef -= equipped.def * countToRemove;

      Item? existingItem = inventory.firstWhere(
            (item) => item.name == itemName,
        orElse: () => Item("", false, 0, false, 0, ""),
      );
      if (existingItem.name.isEmpty) {
        inventory.add(Item(itemName, false, equipped.price, true, countToRemove, equipped.description,
            atk: equipped.atk, def: equipped.def));
      } else {
        existingItem.quantity += countToRemove;
      }

      if (equipped.quantity == 0) {
        equippedItems.remove(equipped);
      }
    }

    print("$itemName $unequipCount개를 장착 해제했습니다. 공격력: $totalAtk, 방어력: $totalDef");
  }
}