import 'products.dart';

class CartItem { // 제품과 수량을 묶어 CartItem 객체를 만들어보도록 haza
  Product product;
  int quantity;

  CartItem(this.product, this.quantity);
}