class CostItem {
  final String name;
  final bool isFixedCostPerUnit;
  final int unitCost;
  final String foodType;
  final double foodPrice;
  int quantity;

  CostItem({
    required this.name,
    required this.isFixedCostPerUnit,
    required this.unitCost,
    required this.foodType,
    required this.quantity,
    required this.foodPrice,
  });

  // Add a method to convert CostItem to a Map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isFixedCostPerUnit': isFixedCostPerUnit,
      'unitCost': unitCost,
      'foodType': foodType,
      'foodPrice': foodPrice,
      'quantity': quantity,
    };
  }
}
