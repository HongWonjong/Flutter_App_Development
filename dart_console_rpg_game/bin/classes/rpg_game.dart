import 'item.dart';
import 'dart:io';
import 'merchants.dart';

class RpgGame {
  int hp_now = 100;
  int hp_max = 100;
  int mp_now = 100;
  int mp_max = 100;
  int atk = 10;
  int def = 10;
  List<Item> merchants_item = Merchants().merchants_item;
  List<Item> inventory = [
    Item("gold", false, 1, false, 50, "이 작은 콘솔 세상의 기본 거래 단위입니다."),
    Item("진짜 그냥 나뭇가지", false, 1, true, atk: 3, 1, "이건 왜 들고 계신거죠?")
  ];

  void dungeon() {

  }

  void shop() async {
    print("---------------------");
    if(inventory[0].quantity < 100) {
      print("대장장이: 아이고 손님요 반갑...뭐고 이 100골드도 없는 걸베이 쉐리는? 바쁘니까 말 걸지 마래이");
      sleep(Duration(seconds: 2));
      print("나레이션: 아무래도 아직 거지와는 상대해주지 않는 듯 하다..");
    };
    if(inventory[0].quantity >= 100 && inventory[0].quantity < 250) {
      print("대장장이: 어 그래 왔나. 여 새로 갈아놓은 칼 있으니까 함 보고.");
      sleep(Duration(seconds: 2));
      print("나레이션: 이제 손님 취급은 해 주는 듯 하다.");
    };
    if(inventory[0].quantity >= 200 && inventory[0].quantity < 500) {
      print("대장장이: 아이고 어서 오세요 손님~ 커피라도 한잔 타다 드릴까요?");
      sleep(Duration(seconds: 2));
      print("나레이션: 수상하게 친절해졌다.");
    }
    sleep(Duration(seconds: 2));
    print("---------------------");
    for(int i = 0; i < merchants_item.length; i++) {
      print("${i}. ${merchants_item[i].name} | ${merchants_item[i].price}골드 | ${merchants_item[i].description}");
    }

    print("---------------------");

    print("나레이션: 원하는 아이템을 선택해주세요. (나가려면 9)");
    int choice = int.parse(stdin.readLineSync()!);

    if(choice.isNaN) {
      print("나레이션: 메뉴판에 없는걸 주문했다가 쫒겨났다..");
      sleep(Duration(seconds: 2));

      run();
    };

    if(choice == 9) {
      run();
    }
    for(int i = 0; i < merchants_item.length; i++) {
      if(choice == i && inventory[0].quantity >= merchants_item[choice].price) {
        inventory[0].quantity -= merchants_item[choice].price;
        inventory.add(merchants_item[choice]);
        print("나레이션: ${merchants_item[choice].name}를 구매했습니다.");
        shop();
      }
    }







  }

  void quest() {

  }

  void status_on() {
    print("---------------------");
    print("현재 hp ($hp_now / $hp_max)");
    print("현재 mp ($mp_now / $mp_max)");
    print("--------------------------");
    print("보유 아이템");
    for(Item item in inventory) {
      print("${item.name}| ${item.quantity}개 | ${item.description}");
    }
    print("--------------------------");
    print("나가려면 9를 눌러주세요");
    int choice = int.parse(stdin.readLineSync()!);
    if(choice == 9) {
      run();
    }
  }

  void run () {
    print("---------------------");
    print("당신은 사람들로 북적이는 마을의 한가운데 서 있습니다. 무엇을 하시겟습니까?");
    print("1. 던전으로 모험을 떠난다.");
    print("2. 상인에게 아이템을 구매하러 간다.");
    print("3. 사람들의 이야기를 듣는다.(퀘스트)");
    print("4. 현재 내 상태를 확인한다.");
    print("5. 게임을 종료한다.");
    print("---------------------");
    int choice = int.parse(stdin.readLineSync()!);
    if( choice!= 1 && choice != 2 && choice != 3 && choice != 4 && choice != 5) {
      print("그런 선택은 할 수 없습니다.");
      run();
    }

    switch(choice) {
      case(1):
        dungeon();
        break;
      case(2):
        shop();
        break;
      case(3):
        quest();
        break;
      case(4):
        status_on();
        break;
      case(5):
        break;

    }
  }
}