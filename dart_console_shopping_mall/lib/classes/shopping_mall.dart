import 'dart:io';
import 'product.dart';

class ShoppingMall {
  List<Product> products = [
    Product("신발", 15000),
    Product("가죽벨트", 20000),
    Product("선글라스(특가)", 5000),
    Product("서바이벌 나이프", 25000),
    Product("5개를 채우기 위한 의미 없는 상품", 9999999),
  ];

  // 장바구니를 Map으로 구현, 키는 상품 인덱스(0부터 시작), 값은 수량
  Map<int, int> cart = {}; // 키-값 상품 인덱스 -수량

  void showProductList() {
    print("\n=== 상품 목록 ===");
    for (int i = 0; i < products.length; i++) {
      String cartMessage = "";
      if (cart.containsKey(i) && cart[i]! > 0) { // 장바구니의 인덱스는 products의 인덱스와 같으므로 이렇게 사용 가능.
        cartMessage = " (이 상품을 ${cart[i]}개 담으셨습니다!)";
      }
      print("${i + 1}. ${products[i].name} / ${products[i].price}원$cartMessage");
    }
  }

  void addToCart() {
    showProductList();
    print("\n장바구니에 담을 상품 번호를 입력하세요 (1-${products.length}): ");
    String? productInput = stdin.readLineSync();
    int? productIndex = int.tryParse(productInput ?? ""); // int인지 확인하고 아니라면 null

    // 3가지 조건을 전부 만족해서 1, 2, 3, 4, 5 정수만 받도록 함.
    if (productIndex == null || productIndex < 1 || productIndex > products.length) {
      print("잘못된 상품 번호입니다.");
      return;
    }

    print("수량을 입력하세요: ");
    String? quantityInput = stdin.readLineSync();
    int? quantity = int.tryParse(quantityInput ?? "");

    // 2가지 조건, 즉 0보다 같거나 작지 않은 정수여야 함.
    if (quantity == null || quantity <= 0) {
      print("잘못된 수량입니다.");
      return;
    }

    // Map에서 해당 상품의 기존 수량에 더함으로써 각 인덱스를 products 리스트의 Product 인스턴스의
    //인덱스와 일치시킴으로써 원활한 활용을 가능하게 함.
    int index = productIndex - 1;
    cart[index] = (cart[index] ?? 0) + quantity; // 기존 값을 함께 더해서 갱신하되, 없다면 0 + 추가 수량
    print("${products[index].name} ${quantity}개가 장바구니에 담겼습니다.");
  }

  void showCart() {
    if (cart.isEmpty) {
      print("\n장바구니가 비어 있습니다.");
    } else {
      print("------------------------------------------------------------");
      print("     장바구니(현재 화면에서 6을 눌러 장바구니를 초기화할 수 있습니다.)  ");
      print("------------------------------------------------------------");
      int totalPrice = 0;
      int displayIndex = 1; // 장바구니에 인덱스 보여주는 용 정수 변수 하나 0으로 할당하여 초기화

      cart.forEach((index, quantity) { // Map의 각 키-값에 대하여 함수를 실행할 수 있는 forEach 사용
        if (quantity > 0) {
          int itemTotal = products[index].price * quantity;
          print("$displayIndex. ${products[index].name} - ${quantity}개 - ${itemTotal}원");
          totalPrice += itemTotal;
          displayIndex++;
        }
      });

      print("총 가격: $totalPrice원");
    }

    String? confirmInput = stdin.readLineSync();
    int? confirmChoice = int.tryParse(confirmInput ?? "");

    if (confirmChoice == 6) {
      if (cart.isNotEmpty) { // 카트가 빈 경우 추적하여 분기 만듬.
        print("장바구니를 초기화합니다.");
        cart.clear(); // 장바구니 비우기는 맵의 키-값을 비워서 구현
      } else {
        print("이미 장바구니가 비어있습니다.");
      }
    } else {
      print("메뉴로 되돌아갑니다..");
    }
  }

  bool confirmExit() { // 얘는 true, false만 리턴하며 됨. 5 누르면 true.
    print("\n정말 종료하시겠습니까? (종료하려면 5를 입력하세요): ");
    String? confirmInput = stdin.readLineSync();
    int? confirmChoice = int.tryParse(confirmInput ?? "");

    if (confirmChoice == 5) {
      print("이용해 주셔서 감사합니다 ~ 오늘도 수고하셨습니다.");
      return true;
    } else {
      print("메뉴로 되돌아갑니다..");
      return false;
    }
  }

  void run() {
    // 메인 화면은 꺼지면 안되므로 while (true)로 무한 반복문을 실행하고, 반복문이 언제나 입력 구문, 또는 switch의
    // 다른 함수에서 멈춰있도록 함. 이러면 다른 함수들이 끝났을 때 메인 페이지로 돌아옴.
    while (true) {
      print("------------------------------------------------------------");
      print("[1] 상품 목록 보기  [2] 장바구니에 담기  [3] 장바구니 확인  [4] 종료");
      print("------------------------------------------------------------");

      print("메뉴를 선택하세요 (1-4): ");

      String? input = stdin.readLineSync();
      int? choice = int.tryParse(input ?? "");

      // 정수인지, 정수라면 1, 2, 3, 4  사이인지를 ||(or) 이용하여 만듬.
      if (choice == null || choice < 1 || choice > 4) {
        print("1에서 4 사이의 정수를 입력하세요.");
        continue;
      }

      switch (choice) {
        case 1:
          showProductList();
          break; // break로 현재 반복문을 탈출하면 새로운 반복문이 시작되면 run 메서드 내에서 메인 화면 다시 보여짐.
        case 2:
          addToCart();
          break;
        case 3:
          showCart();
          break;
        case 4:
          if (confirmExit()) {
            return;
          }
          break;
      }
    }
  }
}
