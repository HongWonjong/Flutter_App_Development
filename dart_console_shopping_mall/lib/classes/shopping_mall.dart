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

  // 장바구니를 Map으로 변경: 키는 상품 인덱스(0부터 시작), 값은 수량
  Map<int, int> cart = {};

  void showProductList() {
    print("\n=== 상품 목록 ===");
    for (int i = 0; i < products.length; i++) {
      String cartMessage = "";
      if (cart.containsKey(i) && cart[i]! > 0) {
        cartMessage = " (이 상품을 ${cart[i]}개 담으셨습니다!)";
      }
      print("${i + 1}. ${products[i].name} / ${products[i].price}원$cartMessage");
    }
  }

  void addToCart() {
    showProductList();
    print("\n장바구니에 담을 상품 번호를 입력하세요 (1-${products.length}): ");
    String? productInput = stdin.readLineSync();
    int? productIndex = int.tryParse(productInput ?? "");

    if (productIndex == null || productIndex < 1 || productIndex > products.length) {
      print("잘못된 상품 번호입니다.");
      return;
    }

    print("수량을 입력하세요: ");
    String? quantityInput = stdin.readLineSync();
    int? quantity = int.tryParse(quantityInput ?? "");

    if (quantity == null || quantity <= 0) {
      print("잘못된 수량입니다.");
      return;
    }

    // Map에서 해당 상품의 기존 수량에 더하기
    int index = productIndex - 1;
    cart[index] = (cart[index] ?? 0) + quantity;
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
      int displayIndex = 1;

      cart.forEach((index, quantity) {
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
      if (cart.isNotEmpty) {
        print("장바구니를 초기화합니다.");
        cart.clear();
      } else {
        print("이미 장바구니가 비어있습니다.");
      }
    } else {
      print("메뉴로 되돌아갑니다..");
    }
  }

  bool confirmExit() {
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
    while (true) {
      print("------------------------------------------------------------");
      print("[1] 상품 목록 보기  [2] 장바구니에 담기  [3] 장바구니 확인  [4] 종료");
      print("------------------------------------------------------------");

      print("메뉴를 선택하세요 (1-4): ");

      String? input = stdin.readLineSync();
      int? choice = int.tryParse(input ?? "");

      if (choice == null || choice < 1 || choice > 4) {
        print("1에서 4 사이의 정수를 입력하세요.");
        continue;
      }

      switch (choice) {
        case 1:
          showProductList();
          break;
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
