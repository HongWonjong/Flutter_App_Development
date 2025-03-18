class Item{
  final String name;
  final bool isConsumable; // 소비 가능한가?
  final int price;
  final bool isWearable; // 장착 가능한가?
  final int hp; // 단순 회복
  final int mp;
  final int atk; // 장착의 경우 올려주는 공격력
  final int def; // 장착의 경우 올려주는 방어력
  final int hp_increase; // 최대 수치 증가
  final int mp_increase;
  int quantity; // 수량은?
  final String description; // 설명

   Item(this.name, this.isConsumable, this.price, this.isWearable, this.quantity, this.description,{
     // {}로 감싼 부분은 명시적으로 넣지 않아도 자동으로 설정해 둔 기본 값이 들어간다. 이것을 우리는 명명된 매개변수라고 부르며,
     // {}는 명명된 매개변수를 정의하는 문법이다.
  this.hp = 0,
  this.mp = 0,
  this.atk = 0,
  this.def = 0,
  this.hp_increase = 0,
  this.mp_increase = 0,
  });
}