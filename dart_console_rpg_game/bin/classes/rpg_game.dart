import 'dart:io';
import 'dart:math';
import 'item.dart';
import 'merchant.dart';
import 'skill.dart';
import 'monster.dart';
import 'quest.dart';
import 'player.dart';
import '../functions/monster_skill.dart';
import '../data/monster_list.dart';
import '../functions/monster_health_bar.dart';

class RpgGame {
  final String player_name;
  Player player; // 초기화와 동시에 선언부에서 다른 변수를 참조할 수 없으므로 대신 생성자에서 초기화 리스트를 사용할 것이다.
  List<Item> merchantsItem = Merchants().merchants_item;

  // 그 동안 죽인 몬스터들은 이름-토벌 횟수의 키-값으로 저장된다. 퀘스트 수주나 종료 시 기록을 남길 때 사용한다.
  Map<String, int> killedMonsters = {};


  RpgGame(this.player_name) : player = Player(player_name);


  Future<void> dungeon() async { // 보스 파이트를 제외한 10스테이지는 이 곳에서 진행된다.
    print("---------------------");
    print("$player_name는 던전에 입장했습니다!");
    await Future.delayed(Duration(seconds: 1));

    Random random = Random();
    int stage = 1;
    const int maxStage = 10;

    while (stage <= maxStage && player.hpNow > 0) {
      player.buffAtk = 0;
      player.buffDef = 0;

      List<Monster> availableMonsters = monsterList.where((monster) {
        int stageLevel = stage;
        return monster.level >= stageLevel - 2 && monster.level <= stageLevel + 2;
      }).toList();

      if (availableMonsters.isEmpty) {
        availableMonsters = [monsterList[0]]; // 해당 스테이지 레벨 구간에 해당하는 몬스터가 없다면 오류 처리용으로 커여운 슬라임을 보내주도록 하자.
      }

      // 해당 레벨 구간에 출현 가능한 몬스터들 중 하나를 랜덤으로 소환한다.
      Monster currentMonster = availableMonsters[random.nextInt(availableMonsters.length)];
      int monsterHp = currentMonster.hp; // 몬스터 인스턴스의 데이터를 직접 건드리지 않도록 변수에 저장하여 사용한다.
      int monsterMaxHp = currentMonster.hp;
      int monsterAtk = currentMonster.atk;
      int monsterDef = currentMonster.def;
      print(" "); // 각 스테이지를 구별하기 위한 두 줄 띄어놓기.
      print(" ");

      print("스테이지 $stage: ${currentMonster.name}이 나타났습니다! 체력: ${getHealthBar(monsterHp, monsterMaxHp)} ($monsterHp/$monsterMaxHp)");
      print("몬스터 설명: ${currentMonster.description}");
      await Future.delayed(Duration(seconds: 1));

      while (player.hpNow > 0 && monsterHp > 0) {
        print("$player_name의 HP/MP: ${player.hpNow}/${player.mpNow}, 공격력: ${player.totalAtk}, 방어력: ${player.totalDef}");
        print("몬스터 체력: ${getHealthBar(monsterHp, monsterMaxHp)} ($monsterHp/$monsterMaxHp)");
        print("몬스터 공/방: ATK: ${monsterAtk} / DEF: ${monsterDef}");
        print("몬스터 스킬: ${currentMonster.skill != null ? "스킬 보유" : '없음'}");
        print("1. 공격 | 2. ${player.skills[0].skill_name} | 3. ${player.skills[1].skill_name} | 4. 도망가기 | 5. 아이템 사용");
        int? choice = int.tryParse(stdin.readLineSync() ?? '');

        if (choice == 1) {
          monsterHp -= (player.totalAtk - monsterDef); // 플레이어가 공격하면 몬스터의 방어력만큼 데미지가 감소하겠지.
          monsterHp = monsterHp.clamp(0, monsterMaxHp);
          print("$player_name가 몬스터에게 ${player.totalAtk - monsterDef} 데미지를 입혔습니다! (남은 체력: ${getHealthBar(monsterHp, monsterMaxHp)})");
          await Future.delayed(Duration(seconds: 1));
        } else if (choice == 2) {
          player.useSkill(player.skills[0]);
          await Future.delayed(Duration(seconds: 1));
        } else if (choice == 3) {
          player.useSkill(player.skills[1]);
          await Future.delayed(Duration(seconds: 1));
        } else if (choice == 4) {
          print("$player_name는 도망쳤습니다...");
          await Future.delayed(Duration(seconds: 1));
          return;
        } else if (choice == 5) {
          List<Item> consumables = player.inventory.where((item) => item.isConsumable && item.quantity > 0).toList();
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
              player.useItem(itemName);
            } else {
              print("아이템 사용을 취소했습니다.");
            }
            await Future.delayed(Duration(seconds: 1));
          }
        }

        if (monsterHp > 0) {
          if (currentMonster.skill != null) {
            // 패시브 스킬 (continue를 사용하지 않으므로 패시브 스킬 사용 후 일반 공격이 진행)
            if (currentMonster.name == "트롤") {
              currentMonster.skill!(this, currentMonster);
              monsterHp = (monsterHp + 15).clamp(0, monsterMaxHp);
              print("현재 몬스터 체력: $monsterHp/$monsterMaxHp");
            }
            else if (currentMonster.name == "살인거북이" && !currentMonster.skill_used) {
              currentMonster.skill!(this, currentMonster);
              monsterDef += 15;
            }
            else if (currentMonster.name == "미노타우르스" &&
                monsterHp < monsterMaxHp * 0.5 &&
                !currentMonster.skill_used) {
              currentMonster.skill!(this, currentMonster);
              monsterAtk += 20;
              monsterDef += 10;
            }
            // 액티브 스킬 (공격 대신 발동, continue로 다음 턴 이동)
            else if (currentMonster.name == "웨어울프" && random.nextDouble() < 0.5) { //스킬 발동 확률은 50%
              currentMonster.skill!(this, currentMonster);
              await Future.delayed(Duration(seconds: 1));
              continue;
            }
            else if (currentMonster.name == "마법사 유령" && random.nextDouble() < 0.5) {
              currentMonster.skill!(this, currentMonster);
              await Future.delayed(Duration(seconds: 1));
              continue;
            }
            else if (currentMonster.name == "거대 전갈" && random.nextDouble() < 0.5) {
              currentMonster.skill!(this, currentMonster);
              await Future.delayed(Duration(seconds: 1));
              continue;
            }
          }

          int damage = (monsterAtk - player.totalDef).clamp(0, monsterAtk);
          player.hpNow -= damage;
          print("$player_name를 ${currentMonster.name}가 공격! $damage 데미지를 입었습니다. (HP: ${player.hpNow})");
          await Future.delayed(Duration(seconds: 1));
        } else {
          print("$player_name는 ${currentMonster.name}을 처치했습니다! 보상: ${stage * 10}골드");
          if (killedMonsters.containsKey(currentMonster.name)) {
            killedMonsters[currentMonster.name] = killedMonsters[currentMonster.name]! + 1;
          } else {
            killedMonsters[currentMonster.name] = 1;
          }
          player.inventory[0].quantity += stage * 10;
          stage++;
          await Future.delayed(Duration(seconds: 1));
          break;
        }

        if (player.hpNow <= 0) {
          print("$player_name는 사망했습니다... 골드가 반으로 줄어듭니다."); // 사망하면 마을로 골드 절반을 잃고 돌아간다.
          player.inventory[0].quantity ~/= 2;
          player.hpNow = player.hpMax;
          player.buffAtk = 0;
          player.buffDef = 0;
          await Future.delayed(Duration(seconds: 2));
          return;
        }
      }
    }

    if (stage > maxStage) {
      print("$player_name가 던전 10 스테이지를 모두 클리어하자, 눈 앞에 커다란 문이 나타납니다."); //  보스 스테이지 앞에 왔을 경우
      await Future.delayed(Duration(seconds: 2));
      print("커다란 문 뒤에서 형언할 수 없는 무언가의 존재감이 느껴진다..");
      await Future.delayed(Duration(seconds: 2));
      print("입장하시겠습니까?");
      print("1: 들어간다. | 2: 돌아간다. (그 외를 누르면 마을로 돌아갑니다.)");
      int? choice = int.tryParse(stdin.readLineSync() ?? '');

      if (choice == 1) {
        await fightBoss();
      } else {
        print("$player_name는 마을로 돌아갑니다.");
        await Future.delayed(Duration(seconds: 2));
      }
    }
  }

  Future<void> fightBoss() async {
    BossMonster boss = bossList[0]; // 현재로써는 보스가 하나 뿐이다. 추후 만들게 된다면 전 단계에서 어떤 레벨의 보스를 소환할지 매개변수를 전달해주자.
    int bossHp = boss.hp;
    int bossMaxHp = boss.hp;
    int bossAtk = boss.atk;
    int bossDef = boss.def;
    Random random = Random();
    print("---------------------");
    print("$player_name가 문을 열고 들어가자, 어두운 방 한 가운데에 무언가 거대한 것의 실루엣이 꿈틀거린다."); // 보스 소개 문구
    await Future.delayed(Duration(seconds: 2));
    print("Y’AI ’NG’NGAH, YOG-SOTHOTH H’EE—L’GEB F’AI THRODOG UAAAH"); // 크툴루 나무위키에서 긁어 옴.
    await Future.delayed(Duration(seconds: 2));
    print("불길한 목소리의 중얼거림이 방 안을 가득 채운다.");
    await Future.delayed(Duration(seconds: 2));
    print("OGTHROD AI’F GEB’L—EE’H YOG-SOTHOTH ‘NGAH’NG AI’Y ZHRO!");
    await Future.delayed(Duration(seconds: 2));
    print("따라할 수 조차 없는 찬양들이 외신을 둘러싸고 시끄럽게 울려퍼진다.");
    await Future.delayed(Duration(seconds: 1));
    print("${boss.name}가 나타났습니다! 체력: ${getHealthBar(bossHp, bossMaxHp)} ($bossHp/$bossMaxHp)");
    await Future.delayed(Duration(seconds: 2));
    print("${boss.description}");
    await Future.delayed(Duration(seconds: 2));

    while (player.hpNow > 0 && bossHp > 0) {
      print("$player_name의 HP/MP: ${player.hpNow}/${player.mpNow}, 공격력: ${player.totalAtk}, 방어력: ${player.totalDef}");
      print("보스 체력: ${getHealthBar(bossHp, bossMaxHp)} ($bossHp/$bossMaxHp)"); //
      print("몬스터 공/방: ATK: ${bossAtk} / DEF: ${bossDef}");
      print("1. 공격 | 2. 스킬 사용 (광분) | 3. 스킬 사용 (방패 올리기) | 4. 도망가기 | 5. 아이템 사용");
      int? choice = int.tryParse(stdin.readLineSync() ?? '');

      if (choice == 1) {
        bossHp -= player.totalAtk;
        bossHp = bossHp.clamp(0, bossMaxHp);
        print("$player_name은 보스에게 ${player.totalAtk} 데미지를 입혔습니다! (보스의 남은 체력: ${getHealthBar(bossHp, bossMaxHp)})");
        await Future.delayed(Duration(seconds: 1));
      } else if (choice == 2) {
        player.useSkill(player.skills[0]);
        await Future.delayed(Duration(seconds: 1));
      } else if (choice == 3) {
        player.useSkill(player.skills[1]);
        await Future.delayed(Duration(seconds: 1));
      } else if (choice == 4) {
        print("$player_name은 도망쳤습니다...");
        await Future.delayed(Duration(seconds: 1));
        return;
      } else if (choice == 5) {
        List<Item> consumables = player.inventory.where((item) => item.isConsumable && item.quantity > 0).toList();
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
            player.useItem(itemName);
          } else {
            print("아이템 사용을 취소했습니다.");
          }
          await Future.delayed(Duration(seconds: 1));
        }
      }

      // 보스가 살아있을 때만 스킬 실행
      if (bossHp > 0) {
        int skillIndex = random.nextInt(boss.bossSkills.length);
        var selectedSkill = boss.bossSkills[skillIndex];

        // 비동기 스킬(tentaclePush)일 경우 await로 대기한다. 다단 히트는 매 히트 사이에 딜레이가 있어야 두들겨 맞는 즐거움이 있기 때문.
        if (selectedSkill == tentaclePush) {
          await selectedSkill(this, boss);
        } else {
          selectedSkill(this, boss);
          await Future.delayed(Duration(seconds: 2)); // 동기 스킬은 기본 딜레이만 부여
        }
      } else {
        print("$player_name은 ${boss.name}를 물리쳤습니다! 보상: 500골드");
        player.inventory[0].quantity += 500;
        print("마을로 돌아갑니다.");
        await Future.delayed(Duration(seconds: 2));
        return;
      }

      if (player.hpNow <= 0) {
        print("사망했습니다... 골드가 반으로 줄어듭니다.");
        player.inventory[0].quantity ~/= 2;
        player.hpNow = player.hpMax;
        player.buffAtk = 0;
        player.buffDef = 0;
        await Future.delayed(Duration(seconds: 2));
        return;
      }
    }
  }

  Future<void> shop() async {
    print("---------------------");
    if (player.inventory[0].quantity < 100) {
      print("상인: 아이고 손님 반갑...뭐야 거지잖아?");
      await Future.delayed(Duration(seconds: 1));
      print("나레이션: 아무래도 아직 거지와는 상대해주지 않는 듯 하다..100골드를 모아 와보자.");
    } else if (player.inventory[0].quantity >= 100 && player.inventory[0].quantity < 250) {
      print("상인: 어 그래 왔나. 여 새로 갈아놓은 칼 있으니까 함 보고.");
      await Future.delayed(Duration(seconds: 1));
      print("나레이션: 이제 손님 취급은 해 주는 듯 하다. 200골드를 모아와보자.");
    } else if (player.inventory[0].quantity >= 200) {
      print("상인: 아이고 어서 오세요 손님~ 커피라도 한잔 타다 드릴까요?");
      await Future.delayed(Duration(seconds: 1));
      print("나레이션: 친절해졌다.");
    }
    await Future.delayed(Duration(seconds: 1));
    await shopMenu();
  }

  Future<void> shopMenu() async {
    bool inShop = true;
    while (inShop) {
      print("---------------------");
      print("현재 소지 골드: ${player.inventory[0].quantity}");
      for (int i = 0; i < merchantsItem.length; i++) {
        print("${i}. ${merchantsItem[i].name} | ${merchantsItem[i].price}골드 | ${merchantsItem[i].description}");
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
      } else if (choice >= 0 && choice < merchantsItem.length) {
        if (player.inventory[0].quantity >= merchantsItem[choice].price) {
          player.inventory[0].quantity -= merchantsItem[choice].price;
          Item purchased = merchantsItem[choice];
          Item? existingItem = player.inventory.firstWhere(
                (item) => item.name == purchased.name,
            orElse: () => Item("", false, 0, false, 0, ""),
          );
          if (existingItem.name.isEmpty) {
            player.inventory.add(Item(purchased.name, purchased.isConsumable, purchased.price, purchased.isWearable, 1,
                purchased.description, hp: purchased.hp, mp: purchased.mp, atk: purchased.atk,
                def: purchased.def, hp_increase: purchased.hp_increase, mp_increase: purchased.mp_increase));
          } else {
            existingItem.quantity += 1;
          }
          print("나레이션: ${purchased.name}를 구매했습니다.");
          await Future.delayed(Duration(seconds: 1));
        } else {
          print("나레이션: $player_name은 돈이 부족합니다.");
          await Future.delayed(Duration(seconds: 1));
        }
      }
      player.inventory.removeWhere((item) => item.quantity == 0 && item.name != "gold");
    }
  }

  Future<void> quest() async {
    bool inQuest = true;
    while (inQuest) {
      print("---------------------");
      print("마을 사람들의 이야기 (퀘스트 목록):");

      List<Quest> availableQuests = questList.where((q) => !q.is_completed).toList();
      if (availableQuests.isEmpty) {
        print("현재 수락할 수 있는 퀘스트가 없습니다.");
      } else {
        for (int i = 0; i < availableQuests.length; i++) {
          Quest q = availableQuests[i];
          int currentKills = killedMonsters[q.monster_name] ?? 0;
          String status = q.is_accepted ? " [수주 중]" : "";
          print("$i. ${q.quest_name}$status | ${q.quest_description}");
          print("   목표: ${q.monster_name} ${q.monster_kill_count}마리 처치 (현재: $currentKills/${q.monster_kill_count})");
          print("   보상: ${q.reward_gold}골드");
        }
      }
      print("---------------------");
      print("퀘스트를 선택하세요 (번호 입력) / 보상 받기: '완료 [번호]' / 나가기: 9");

      String? input = stdin.readLineSync();
      if (input == "9") {
        inQuest = false;
        print("마을로 돌아갑니다.");
      } else if (input != null && input.startsWith("완료 ")) {
        List<String> parts = input.split(" ");
        if (parts.length == 2) {
          int? questIndex = int.tryParse(parts[1]);
          if (questIndex != null && questIndex >= 0 && questIndex < availableQuests.length) {
            Quest selectedQuest = availableQuests[questIndex];
            int currentKills = killedMonsters[selectedQuest.monster_name] ?? 0;
            if (currentKills >= selectedQuest.monster_kill_count) {
              selectedQuest.is_completed = true;
              selectedQuest.is_accepted = false;
              player.inventory[0].quantity += selectedQuest.reward_gold;
              print("${selectedQuest.quest_name} 퀘스트 완료! 보상 ${selectedQuest.reward_gold}골드를 받았습니다.");

            } else {
              print("아직 ${selectedQuest.monster_name}을 ${selectedQuest.monster_kill_count}마리 처치하지 못했습니다. (현재: $currentKills)");
            }
          } else {
            print("잘못된 퀘스트 번호입니다.");
          }
        } else {
          print("형식이 잘못되었습니다. '완료 [번호]'로 입력해주세요.");
        }
      } else {
        int? choice = int.tryParse(input ?? '');
        if (choice != null && choice >= 0 && choice < availableQuests.length) {
          Quest selectedQuest = availableQuests[choice];
          if (selectedQuest.is_accepted) {
            print("${selectedQuest.quest_name}은 이미 수주 중입니다!");
          } else {
            selectedQuest.is_accepted = true;
            print("${selectedQuest.quest_name} 퀘스트를 수락했습니다. ${selectedQuest.monster_name}을 ${selectedQuest.monster_kill_count}마리 처치하세요!");
          }
        } else {
          print("잘못된 선택입니다.");
        }
      }
      await Future.delayed(Duration(seconds: 1));
    }
  }

  Future<void> statusOn() async{ // 인벤토리, 플레이어 상태, 장비칸을 구분하지 않고 뭉쳐놨다.
    print("$player_name은 가방을 꺼내서 뒤적거려봅니다...");
    bool inStatus = true;
    while (inStatus) {
      await Future.delayed(Duration(seconds: 1));
      print("---------------------");
      print("현재 hp (${player.hpNow} / ${player.hpMax})");
      print("현재 mp (${player.mpNow} / ${player.mpMax})");
      print("공격력: ${player.totalAtk} | 방어력: ${player.totalDef}");
      print("--------------------------");
      print("보유 아이템");
      for (Item item in player.inventory) {
        String wearableText = item.isWearable ? " | 장착 가능" : "";
        String consumableText = item.isConsumable ? " | 소비 가능" : "";
        print("${item.name} | ${item.quantity}개 | ${item.description}$wearableText$consumableText");
      }
      print("--------------------------");
      print("장착 중인 아이템");
      if (player.equippedItems.isEmpty) {
        print("없음");
      } else {
        for (Item item in player.equippedItems) {
          print("${item.name} | ${item.quantity}개 | ${item.description}");
        }
      }
      print("--------------------------");
      print("보유 스킬");
      for (Skill skill in player.skills) {
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
            player.unequipItem(itemName, unequipCount);
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
            player.equipItem(itemName, equipCount);
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
          player.useItem(itemName);
        } else {
          print("형식이 잘못되었습니다. '사용 [아이템 이름]'로 입력해주세요.");
        }
      }
    }
  }

  Future<void> saveGameRecord() async {
    final file = File('game_record.csv');
    bool cthulhuDefeated = killedMonsters.containsKey("외신 크툴루") && killedMonsters["외신 크툴루"]! > 0;

    List<String> monsterNames = [
      ...monsterList.map((m) => m.name),
      ...bossList.map((b) => b.name),
    ].toSet().toList();

    String csvHeader = "PlayerID,HP,MP,MaxHP,MaxMP,Attack,Defense,${monsterNames.join(',')},CthulhuDefeated\n";

    String playerId = player_name;

    String csvData = "플레이어 $playerId,${player.hpNow},${player.mpNow},${player.hpMax},${player.mpMax},${player.totalAtk},${player.totalDef}";
    for (String monster in monsterNames) {
      csvData += ",${killedMonsters[monster] ?? 0}";
    }
    csvData += ",$cthulhuDefeated\n";

    try {
      if (!await file.exists()) {
        await file.writeAsString(csvHeader + csvData);
      } else {
        await file.writeAsString(csvData, mode: FileMode.append);
      }
      print("게임 기록이 'game_record.csv' 파일에 저장되었습니다.");
    } catch (e) {
      print("기록 저장 중 오류 발생: $e");
    }
  }

  Future<void> run() async {
    bool running = true;
    while (running) {
      print("---------------------");
      print("$player_name은 사람들로 북적이는 마을의 한가운데 서 있습니다. 무엇을 하시겠습니까?");
      print("1. 던전으로 모험을 떠난다.");
      print("2. 상인에게 아이템을 구매하러 간다.");
      print("3. 사람들의 이야기를 듣는다.(퀘스트)");
      print("4. $player_name의 상태 확인");
      print("5. 게임 종료");
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
          await quest();
          break;
        case 4:
          await statusOn();
          break;
        case 5:
          print("정말 종료하시겠습니까? $player_name의 일대기는 영원히 기록될 것입니다.");
          print("9를 한번 더 누르면 종료됩니다. (그 외는 취소)");
          int? confirmChoice = int.tryParse(stdin.readLineSync() ?? '');
          if (confirmChoice == 9) {
            await saveGameRecord();
            running = false;
            print("게임을 종료합니다.");
          } else {
            print("종료가 취소되었습니다.");
            await Future.delayed(Duration(seconds: 1));
          }
          break;
      }
    }
  }
}