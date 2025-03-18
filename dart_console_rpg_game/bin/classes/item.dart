class Item{
  final String name;
  final bool isConsumable;
  final int price;
  final bool wearable;
  final int hp;
  final int mp;
  final int atk;
  final int def;
  final int hp_increase;
  final int mp_increase;
  int quantity;
  final String description;

   Item(this.name, this.isConsumable, this.price, this.wearable, this.quantity, this.description,{
  this.hp = 0,
  this.mp = 0,
  this.atk = 0,
  this.def = 0,
  this.hp_increase = 0,
  this.mp_increase = 0,
  });
}