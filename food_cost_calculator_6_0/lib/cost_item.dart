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
}