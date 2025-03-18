import 'dart:io';
import 'dart:math';
import 'item.dart';
import 'merchant.dart';
import 'skill.dart';
import 'monster.dart';

class RpgGame {
  int hp_now = 100;
  int hp_max = 100;
  int mp_now = 100;
  int mp_max = 100;
  int base_atk = 10;
  int base_def = 10;
  int buff_atk = 0;
  int buff_def = 0;
  int item_atk = 0;
  int item_def = 0;
  List<Item> merchants_item = Merchants().merchants_item;
  List<Item> inventory = [
    Item("gold", false, 1, false, 50, "이 작은 콘솔 세상의 기본 거래 단위입니다."),
    Item("진짜_그냥_나뭇가지", false, 1, true, 1, "이건 왜 들고 계신거죠?", atk: 3),
  ];
  List<Item> equippedItems = []; // 사용자가 직접 장착할 수 있는 아이템들은 여기에 장착할 수 있다. 칼을 여러개 장착 할 수도 있도록 해둠.

  List<Skill> skills = [
    Skill("광분", "일시적으로 공격력을 증가시킵니다.", 10, false, 10, false, true, false),
    Skill("방패 올리기", "방패를 들어 방어력을 일시적으로 증가시킵니다. (방패가 있어야 사용 가능)", 10, false, 10, false, true, false),
  ];

  int get total_atk => base_atk + buff_atk + item_atk;
  int get total_def => base_def + buff_def + item_def;

  String getHealthBar(int currentHp, int maxHp) {
    const int barLength = 10;
    int filledBlocks = ((currentHp / maxHp) * barLength).round();
    filledBlocks = filledBlocks.clamp(0, barLength);
    String bar = "█" * filledBlocks + "□" * (barLength - filledBlocks);
    return bar;
  }

  void useSkill(Skill skill) {
    if (mp_now < skill.skill_mp_cost) {
      print("MP가 부족합니다.");
      return;
    }
    if (skill.skill_name == "방패 올리기") {
      if (!inventory.any((item) => item.name == "나무_방패") && !equippedItems.any((item) => item.name == "나무_방패")) {
        print("나무 방패가 없어 방패 올리기 스킬을 사용할 수 없습니다.");
        return;
      }
      mp_now -= skill.skill_mp_cost;
      buff_def = skill.skill_damage_calculation.toInt();
      print("${skill.skill_name} 사용! 방어력이 $total_def로 증가했습니다.");
    } else if (skill.skill_name == "광분") {
      mp_now -= skill.skill_mp_cost;
      buff_atk = skill.skill_damage_calculation.toInt();
      print("${skill.skill_name} 사용! 공격력이 $total_atk로 증가했습니다.");
    } else if (skill.is_attack) {
      mp_now -= skill.skill_mp_cost;
      int damage = (total_atk * skill.skill_damage_calculation).toInt();
      print("${skill.skill_name} 사용! 데미지: $damage");
    } else if (skill.is_heal) {
      mp_now -= skill.skill_mp_cost;
      hp_now = (hp_now + skill.skill_damage_calculation).clamp(0, hp_max).toInt();
      print("${skill.skill_name} 사용! HP가 $hp_now로 회복되었습니다.");
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
      hp_now = (hp_now + item.hp).clamp(0, hp_max).toInt();
      print("${item.name}을 사용했습니다! HP가 $hp_now로 회복되었습니다.");
    }
    if (item.mp > 0) {
      mp_now = (mp_now + item.mp).clamp(0, mp_max).toInt();
      print("${item.name}을 사용했습니다! MP가 $mp_now로 회복되었습니다.");
    }
    if (item.atk > 0 || item.def > 0) {
      buff_atk += item.atk;
      buff_def += item.def;
      print("${item.name}을 사용했습니다! 공격력: $total_atk, 방어력: $total_def");
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

    item_atk += item.atk * equipCount;
    item_def += item.def * equipCount;
    print("$itemName $equipCount개를 장착했습니다. 공격력: $total_atk, 방어력: $total_def");

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

      item_atk -= equipped.atk * countToRemove;
      item_def -= equipped.def * countToRemove;

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

    print("$itemName $unequipCount개를 장착 해제했습니다. 공격력: $total_atk, 방어력: $total_def");
  }

  Future<void> dungeon() async {
    print("---------------------");
    print("던전에 입장했습니다!");
    await Future.delayed(Duration(seconds: 1));

    Random random = Random();
    int stage = 1;
    const int maxStage = 10;

    while (stage <= maxStage && hp_now > 0) {
      buff_atk = 0;
      buff_def = 0;

      List<Monster> availableMonsters = monsterList.where((monster) {
        int stageLevel = stage;
        return monster.level >= stageLevel - 2 && monster.level <= stageLevel + 2;
      }).toList();

      if (availableMonsters.isEmpty) {
        availableMonsters = [monsterList[0]];
      }

      Monster currentMonster = availableMonsters[random.nextInt(availableMonsters.length)];
      int monsterHp = currentMonster.hp;
      int monsterMaxHp = currentMonster.hp;
      int monsterAtk = currentMonster.atk;
      int monsterDef = currentMonster.def;
      print("스테이지 $stage: ${currentMonster.name}이 나타났습니다! 체력: ${getHealthBar(monsterHp, monsterMaxHp)} ($monsterHp/$monsterMaxHp)");
      print("${currentMonster.description}");
      await Future.delayed(Duration(seconds: 1));

      while (hp_now > 0 && monsterHp > 0) {
        print("당신 HP: $hp_now, 공격력: $total_atk, 방어력: $total_def");
        print("몬스터 체력: ${getHealthBar(monsterHp, monsterMaxHp)} ($monsterHp/$monsterMaxHp)");
        print("1. 공격 | 2. ${skills[0].skill_name} | 3. ${skills[1].skill_name} | 4. 도망가기 | 5. 아이템 사용");
        int? choice = int.tryParse(stdin.readLineSync() ?? '');

        if (choice == 1) {
          monsterHp -= total_atk;
          monsterHp = monsterHp.clamp(0, monsterMaxHp);
          print("몬스터에게 $total_atk 데미지를 입혔습니다! (남은 체력: ${getHealthBar(monsterHp, monsterMaxHp)})");
          await Future.delayed(Duration(seconds: 1));
        } else if (choice == 2) {
          useSkill(skills[0]); // 광분
          await Future.delayed(Duration(seconds: 1));
        } else if (choice == 3) {
          useSkill(skills[1]); // 방패 올리기
          await Future.delayed(Duration(seconds: 1));
        } else if (choice == 4) {
          print("도망쳤습니다...");
          await Future.delayed(Duration(seconds: 1));
          return;
        } else if (choice == 5) {
          // 소비 아이템 목록 표시
          List<Item> consumables = inventory.where((item) => item.isConsumable && item.quantity > 0).toList();
          if (consumables.isEmpty) {
            print("소비 가능한 아이템이 없습니다.");
            await Future.delayed(Duration(seconds: 1));
          } else {
            print("---------------------");
            print("소비 가능 아이템:");
            for (Item item in consumables) {
              print("${item.name} | ${item.quantity}개");
            }
            print("---------------------");
            print("사용할 아이템 이름을 입력하세요 (취소하려면 '취소' 입력):");
            String? itemName = stdin.readLineSync();
            if (itemName != null && itemName.toLowerCase() != "취소") {
              useItem(itemName);
            } else {
              print("아이템 사용을 취소했습니다.");
            }
            await Future.delayed(Duration(seconds: 1));
          }
        }

        if (monsterHp > 0) {
          if (currentMonster.skill != null) {
            if (currentMonster.name == "미노타우르스" &&
                monsterHp < monsterMaxHp * 0.5 &&
                !currentMonster.skill_used) {
              currentMonster.skill!(this, currentMonster);
              monsterAtk += 20;
              monsterDef += 10;
            } else if (currentMonster.name == "웨어울프" &&
                random.nextDouble() < 0.3) {
              currentMonster.skill!(this, currentMonster);
              await Future.delayed(Duration(seconds: 1));
              continue;
            }
          }

          int damage = (monsterAtk - total_def).clamp(0, monsterAtk);
          hp_now -= damage;
          print("몬스터가 공격! $damage 데미지를 입었습니다. (HP: $hp_now)");
          await Future.delayed(Duration(seconds: 1));
        } else {
          print("${currentMonster.name}을 처치했습니다! 보상: ${stage * 10}골드");
          inventory[0].quantity += stage * 10;
          stage++;
          await Future.delayed(Duration(seconds: 1));
          break;
        }

        if (hp_now <= 0) {
          print("사망했습니다... 골드가 반으로 줄어듭니다.");
          inventory[0].quantity ~/= 2;
          hp_now = hp_max;
          buff_atk = 0;
          buff_def = 0;
          await Future.delayed(Duration(seconds: 2));
          return;
        }
      }
    }

    if (stage > maxStage) {
      print("던전 10 스테이지를 모두 클리어하자, 눈 앞에 커다란 문이 나타납니다.");
      await Future.delayed(Duration(seconds: 2));
      print("커다란 문 뒤에서 형언할 수 없는 무언가의 존재감이 느껴진다..");
      await Future.delayed(Duration(seconds: 2));
      print("입장하시겠습니까?");
      print("1: 들어간다. | 2: 돌아간다. (그 외는 자동으로 돌아감)");
      int? choice = int.tryParse(stdin.readLineSync() ?? '');

      if (choice == 1) {
        await fightBoss();
      } else {
        print("마을로 돌아갑니다.");
        await Future.delayed(Duration(seconds: 2));
      }
    }
  }

  Future<void> fightBoss() async {
    BossMonster boss = bossList[0]; // 첫 번째 보스는 외신 크툴루임. 두 번째 보스 만들지는 잘 모르겠다.
    int bossHp = boss.hp;
    int bossMaxHp = boss.hp;
    Random random = Random();
    print("---------------------");
    print("어두운 방 한 가운데에 무언가 거대한 것의 실루엣이 꿈틀거린다.");
    await Future.delayed(Duration(seconds: 2));
    print("Y’AI ’NG’NGAH, YOG-SOTHOTH H’EE—L’GEB F’AI THRODOG UAAAH");
    await Future.delayed(Duration(seconds: 2));
    print("OGTHROD AI’F GEB’L—EE’H YOG-SOTHOTH ‘NGAH’NG AI’Y ZHRO!");
    await Future.delayed(Duration(seconds: 2));
    print("따라할 수 조차 없는 찬양들이 외신을 둘러싸고 시끄럽게 울려퍼진다.");
    await Future.delayed(Duration(seconds: 2));
    print("${boss.name}가 나타났습니다! 체력: ${getHealthBar(bossHp, bossMaxHp)} ($bossHp/$bossMaxHp)");
    print("${boss.description}");
    await Future.delayed(Duration(seconds: 2));

    while (hp_now > 0 && bossHp > 0) {
      print("당신 HP: $hp_now, 공격력: $total_atk, 방어력: $total_def");
      print("보스 체력: ${getHealthBar(bossHp, bossMaxHp)} ($bossHp/$bossMaxHp)");
      print("1. 공격 | 2. 스킬 사용 (광분) | 3. 스킬 사용 (방패 올리기) | 4. 도망가기 | 5. 아이템 사용");
      int? choice = int.tryParse(stdin.readLineSync() ?? '');

      if (choice == 1) {
        bossHp -= total_atk;
        bossHp = bossHp.clamp(0, bossMaxHp);
        print("보스에게 $total_atk 데미지를 입혔습니다! (남은 체력: ${getHealthBar(bossHp, bossMaxHp)})");
        await Future.delayed(Duration(seconds: 1));
      } else if (choice == 2) {
        useSkill(skills[0]);
        await Future.delayed(Duration(seconds: 1));
      } else if (choice == 3) {
        useSkill(skills[1]);
        await Future.delayed(Duration(seconds: 1));
      } else if (choice == 4) {
        print("도망쳤습니다...");
        await Future.delayed(Duration(seconds: 1));
        return;
      } else if (choice == 5) {

        List<Item> consumables = inventory.where((item) => item.isConsumable && item.quantity > 0).toList();
        if (consumables.isEmpty) {
          print("소비 가능한 아이템이 없습니다.");
          await Future.delayed(Duration(seconds: 1));
        } else {
          print("---------------------");
          print("소비 가능 아이템:");
          for (Item item in consumables) {
            print("${item.name} | ${item.quantity}개");
          }
          print("---------------------");
          print("사용할 아이템 이름을 입력하세요 (취소하려면 '취소' 입력):");
          String? itemName = stdin.readLineSync();
          if (itemName != null && itemName.toLowerCase() != "취소") {
            useItem(itemName);
          } else {
            print("아이템 사용을 취소했습니다.");
          }
          await Future.delayed(Duration(seconds: 1));
        }
      }

      if (bossHp > 0) {

        int skillIndex = random.nextInt(boss.bossSkills.length);
        boss.bossSkills[skillIndex](this, boss);
        await Future.delayed(Duration(seconds: 2));
      } else {
        print("${boss.name}를 물리쳤습니다! 보상: 500골드");
        inventory[0].quantity += 500;
        print("마을로 돌아갑니다.");
        await Future.delayed(Duration(seconds: 2));
        return;
      }

      if (hp_now <= 0) {
        print("사망했습니다... 골드가 반으로 줄어듭니다.");
        inventory[0].quantity ~/= 2;
        hp_now = hp_max;
        buff_atk = 0;
        buff_def = 0;
        await Future.delayed(Duration(seconds: 2));
        return;
      }
    }
  }

  Future<void> shop() async {
    print("---------------------");
    if (inventory[0].quantity < 100) {
      print("대장장이: 아이고 손님요 반갑...뭐고 이 100골드도 없는 걸베이 쉐리는? 바쁘니까 말 걸지 마래이");
      await Future.delayed(Duration(seconds: 1));
      print("나레이션: 아무래도 아직 거지와는 상대해주지 않는 듯 하다..");
    } else if (inventory[0].quantity >= 100 && inventory[0].quantity < 250) {
      print("대장장이: 어 그래 왔나. 여 새로 갈아놓은 칼 있으니까 함 보고.");
      await Future.delayed(Duration(seconds: 1));
      print("나레이션: 이제 손님 취급은 해 주는 듯 하다.");
    } else if (inventory[0].quantity >= 200) {
      print("대장장이: 아이고 어서 오세요 손님~ 커피라도 한잔 타다 드릴까요?");
      await Future.delayed(Duration(seconds: 1));
      print("나레이션: 수상하게 친절해졌다.");
    }
    await Future.delayed(Duration(seconds: 1));
    await shopMenu();
  }

  Future<void> shopMenu() async {
    bool inShop = true;
    while (inShop) {
      print("---------------------");
      print("현재 소지 골드: ${inventory[0].quantity}");
      for (int i = 0; i < merchants_item.length; i++) {
        print("${i}. ${merchants_item[i].name} | ${merchants_item[i].price}골드 | ${merchants_item[i].description}");
      }
      print("---------------------");

      print("나레이션: 원하는 아이템을 선택해주세요. (나가려면 9)");
      int? choice = int.tryParse(stdin.readLineSync() ?? '');

      if (choice == null) {
        print("나레이션: 메뉴판에 없는걸 주문했다가 쫒겨났다..");
        await Future.delayed(Duration(seconds: 2));
        inShop = false;
      } else if (choice == 9) {
        inShop = false;
      } else if (choice >= 0 && choice < merchants_item.length) {
        if (inventory[0].quantity >= merchants_item[choice].price) {
          inventory[0].quantity -= merchants_item[choice].price;
          Item purchased = merchants_item[choice];
          Item? existingItem = inventory.firstWhere(
                (item) => item.name == purchased.name,
            orElse: () => Item("", false, 0, false, 0, ""),
          );
          if (existingItem.name.isEmpty) {
            inventory.add(Item(purchased.name, purchased.isConsumable, purchased.price, purchased.wearable, 1,
                purchased.description, hp: purchased.hp, mp: purchased.mp, atk: purchased.atk, def: purchased.def));
          } else {
            existingItem.quantity += 1;
          }
          print("나레이션: ${purchased.name}를 구매했습니다.");
          await Future.delayed(Duration(seconds: 1));
        } else {
          print("나레이션: 돈이 부족합니다.");
          await Future.delayed(Duration(seconds: 1));
        }
      }
      inventory.removeWhere((item) => item.quantity == 0 && item.name != "gold");
    }
  }

  void quest() {
    // 아직 구현 안 함
  }

  void status_on() {
    bool inStatus = true;
    while (inStatus) {
      print("---------------------");
      print("현재 hp ($hp_now / $hp_max)");
      print("현재 mp ($mp_now / $mp_max)");
      print("공격력: $total_atk | 방어력: $total_def");
      print("--------------------------");
      print("보유 아이템");
      for (Item item in inventory) {
        String wearableText = item.wearable ? " | 장착 가능" : "";
        String consumableText = item.isConsumable ? " | 소비 가능" : "";
        print("${item.name} | ${item.quantity}개 | ${item.description}$wearableText$consumableText");
      }
      print("--------------------------");
      print("장착 중인 아이템");
      if (equippedItems.isEmpty) {
        print("없음");
      } else {
        for (Item item in equippedItems) {
          print("${item.name} | ${item.quantity}개 | ${item.description}");
        }
      }
      print("--------------------------");
      print("보유 스킬");
      for (Skill skill in skills) {
        print("${skill.skill_name} | ${skill.skill_description} | ${skill.skill_mp_cost} mp 사용");
      }
      print("--------------------------");

      print("나가려면 9를 눌러주세요.");
      print("(아이템 장착: '장착 [이름] [개수]', 해제: '해제 [이름] [개수]', 사용: '사용 [이름]')");
      String? input = stdin.readLineSync();
      if (input == "9") {
        inStatus = false;
      } else if (input != null && input.startsWith("해제 ")) {
        List<String> parts = input.split(" ");
        if (parts.length >= 3) {
          String itemName = parts.sublist(1, parts.length - 1).join(" ");
          int? unequipCount = int.tryParse(parts.last);
          if (unequipCount != null) {
            unequipItem(itemName, unequipCount);
          } else {
            print("개수를 숫자로 입력해주세요.");
          }
        } else {
          print("형식이 잘못되었습니다. '해제 [아이템 이름] [개수]'로 입력해주세요.");
        }
      } else if (input != null && input.startsWith("장착 ")) {
        List<String> parts = input.split(" ");
        if (parts.length >= 3) {
          String itemName = parts.sublist(1, parts.length - 1).join(" ");
          int? equipCount = int.tryParse(parts.last);
          if (equipCount != null) {
            equipItem(itemName, equipCount);
          } else {
            print("개수를 숫자로 입력해주세요.");
          }
        } else {
          print("형식이 잘못되었습니다. '장착 [아이템 이름] [개수]'로 입력해주세요.");
        }
      } else if (input != null && input.startsWith("사용 ")) {
        List<String> parts = input.split(" ");
        if (parts.length >= 2) {
          String itemName = parts.sublist(1).join(" ");
          useItem(itemName);
        } else {
          print("형식이 잘못되었습니다. '사용 [아이템 이름]'로 입력해주세요.");
        }
      }
    }
  }

  Future<void> run() async {
    bool running = true;
    while (running) {
      print("---------------------");
      print("당신은 사람들로 북적이는 마을의 한가운데 서 있습니다. 무엇을 하시겠습니까?");
      print("1. 던전으로 모험을 떠난다.");
      print("2. 상인에게 아이템을 구매하러 간다.");
      print("3. 사람들의 이야기를 듣는다.(퀘스트)");
      print("4. 현재 내 상태를 확인한다.");
      print("5. 게임을 종료한다.");
      print("---------------------");
      int? choice = int.tryParse(stdin.readLineSync() ?? '');

      if (choice == null || (choice != 1 && choice != 2 && choice != 3 && choice != 4 && choice != 5)) {
        print("그런 선택은 할 수 없습니다.");
        await Future.delayed(Duration(seconds: 1));
        continue;
      }

      switch (choice) {
        case 1:
          await dungeon();
          break;
        case 2:
          await shop();
          break;
        case 3:
          quest();
          break;
        case 4:
          status_on();
          break;
        case 5:
          running = false;
          print("게임을 종료합니다.");
          break;
      }
    }
  }
}
