import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '/cost_item.dart';

class CostCalculatorPage extends StatefulWidget {
  final List<CostItem> costList;
  final int quantity;
  final int foodPrice;

  const CostCalculatorPage({super.key,
    required this.costList,
    required this.quantity,
    required this.foodPrice,
  });

  @override
  _CostCalculatorPageState createState() => _CostCalculatorPageState();
}
class _CostCalculatorPageState extends State<CostCalculatorPage> {
  final Map<String, int> _fixedCostByFoodType = {};
  final Map<String, int> _variableCostByFoodType = {};
  late final Map<String, List<CostItem>> _costListByFoodType = {};
  final Map<String, int> _totalRevenueByFoodType = {}; // 추가
  final Map<String, int> _profitByFoodType = {}; // 이 부분을 추가해줍니다.
  int quantity = 1;

  // 수정 시작
  Map<String, List<CostItem>> get costListByFoodType {
    final costListByFoodType = <String, List<CostItem>>{};
    for (var costItem in widget.costList) {
      if (!costListByFoodType.containsKey(costItem.foodType)) {
        costListByFoodType[costItem.foodType] = [];
      }
      costListByFoodType[costItem.foodType]!.add(costItem);
    }
    return costListByFoodType;
  }

  void _calculateCostsByFoodType() {
    _fixedCostByFoodType.clear();
    _variableCostByFoodType.clear();
    _costListByFoodType.clear();
    _totalRevenueByFoodType.clear();
    _profitByFoodType.clear();

    for (var costItem in widget.costList) {
      if (costItem.isFixedCostPerUnit) {
        _fixedCostByFoodType[costItem.foodType] =
            (_fixedCostByFoodType[costItem.foodType] ?? 0) + costItem.unitCost;
      } else {
        _variableCostByFoodType[costItem.foodType] =
            (_variableCostByFoodType[costItem.foodType] ?? 0) + costItem.unitCost;
      }

      if (_costListByFoodType[costItem.foodType] == null) {
        _costListByFoodType[costItem.foodType] = [];
      }
      _costListByFoodType[costItem.foodType]!.add(costItem);
    }

    for (var foodType in _costListByFoodType.keys) {
      int totalVariableCost = _variableCostByFoodType[foodType] ?? 0;
      int totalRevenue = 0;
      int totalCost = 0;
      int totalProfit = 0;

      for (var costItem in _costListByFoodType[foodType]!) {
        if (!costItem.isFixedCostPerUnit) {
          totalVariableCost += costItem.unitCost;
        }
        totalRevenue += costItem.quantity * widget.foodPrice;
        totalCost += (costItem.isFixedCostPerUnit ? costItem.unitCost : costItem.unitCost * costItem.quantity);
      }

      _variableCostByFoodType[foodType] = totalVariableCost;
      _totalRevenueByFoodType[foodType] = totalRevenue;

      int totalFixedCost = _fixedCostByFoodType[foodType] ?? 0;
      totalCost += totalFixedCost;
      totalProfit = totalRevenue - totalCost;
      _profitByFoodType[foodType] = totalProfit;
    }
  }

  double calculateTotalCostRate() {
    double totalCost = 0;
    double totalRevenue = 0;
    for (final foodType in _costListByFoodType.keys) {
      for (final costItem in _costListByFoodType[foodType]!) {
        totalCost += costItem.isFixedCostPerUnit
            ? costItem.unitCost
            : costItem.unitCost * costItem.quantity;
      }
    }
    for (final foodType in _costListByFoodType.keys) {
      for (final costItem in _costListByFoodType[foodType]!) {
        if (costItem == _costListByFoodType[foodType]!.first) {
          totalRevenue += costItem.quantity * costItem.foodPrice;
        }
      }
    }
    double totalCostRate = totalCost / totalRevenue * 100;
    return totalCostRate;
  }
  double calculateFoodCostRate(String foodType) {
    int totalCost = 0;
    double revenue = _costListByFoodType[foodType]!.first.foodPrice * _costListByFoodType[foodType]!.first.quantity;

    for (final costItem in _costListByFoodType[foodType]!) {
      totalCost += costItem.isFixedCostPerUnit
          ? costItem.unitCost
          : costItem.unitCost * costItem.quantity;
    }

    double costRate = (totalCost / revenue) * 100;
    return costRate;
  }




  double calculateTotalRevenue() {
    double totalRevenue = 0;
    for (final foodType in _costListByFoodType.keys) {
      final costList = _costListByFoodType[foodType]!;
      if (costList.isNotEmpty) {
        final costItem = costList.first;
        totalRevenue += costItem.quantity * costItem.foodPrice;
      }
    }
    return totalRevenue;
  }



  int calculateTotalCost() {
    int totalCost = 0;
    for (final foodType in _costListByFoodType.keys) {
      for (final costItem in _costListByFoodType[foodType]!) {
        totalCost += costItem.isFixedCostPerUnit
            ? costItem.unitCost
            : costItem.unitCost * costItem.quantity;
      }
    }
    return totalCost;
  }



  String formatNumber(int value) {
    final formatter = NumberFormat("#,##0");
    return formatter.format(value);
  }

  String formatCurrency(double value) {
    final formatter = NumberFormat("#,##0");
    return formatter.format(value);
  }



  double calculateFixedUnitCost() {
    double totalFixedCost = 0;
    double totalVariableCost = 0;
    int totalQuantity = 0;
    for (var costItem in widget.costList) {
      if (costItem.isFixedCostPerUnit) {
        totalFixedCost += costItem.unitCost;
      } else {
        totalVariableCost += costItem.unitCost * costItem.quantity;
      }
      totalQuantity += costItem.quantity;
    }
    double unitCost = (totalFixedCost + totalVariableCost) / totalQuantity;
    return unitCost;
  }




  @override
  void initState() {
    super.initState();
    _calculateCostsByFoodType();
    quantity = widget.quantity; // 추가
  }
  void _removeCostItem(CostItem costItem) {
    setState(() {
      widget.costList.remove(costItem);
      if (_costListByFoodType.containsKey(costItem.foodType)) {
        _costListByFoodType[costItem.foodType] = _costListByFoodType[costItem.foodType]!
            .where((item) => item != costItem)
            .toList();
      } else {
        _costListByFoodType[costItem.foodType] = [];
      }

      _calculateCostsByFoodType();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "원가 계산",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
          ),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final foodType in _costListByFoodType.keys)
                    ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(foodType),
                          Text('판매량: ${formatNumber(_costListByFoodType[foodType]!.first.quantity)} 개'),
                        ],
                      ),
                      children: [
                        ListTile(
                          title: Text("$foodType의 매출액 & 원가율"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("매출액: ${formatCurrency(_costListByFoodType[foodType]!.first.foodPrice * _costListByFoodType[foodType]!.first.quantity)}원"),
                              Text("원가율: ${formatCurrency(calculateFoodCostRate(foodType))}%"),
                            ],
                          ),
                        ),
                      ] + _costListByFoodType[foodType]!.map(
                            (costItem) => ListTile(
                          title: Text(costItem.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                costItem.isFixedCostPerUnit ? "고정원가" : "변동원가",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${formatNumber(costItem.unitCost)}원",
                              ),
                              if(costItem.isFixedCostPerUnit) Text(
                                  "개당 고정원가: ${formatCurrency(costItem.unitCost.toDouble() / _costListByFoodType[foodType]!.first.quantity)}원"
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _removeCostItem(costItem);
                                },
                                icon: const Icon(Icons.close),
                              ),
                              Text(
                                costItem.isFixedCostPerUnit
                                    ? "합계: ${formatNumber(costItem.unitCost)}원"
                                    : "합계: ${formatNumber(costItem.unitCost * _costListByFoodType[foodType]!.first.quantity)}원",
                              ),
                            ],
                          ),
                        ),
                      ).toList(),
                    ),
                ],
              ),
            ),
          ),
          Card(
            child: ListTile(
              tileColor: Colors.blueGrey,
              title: const Text(
                "총 매출액",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              trailing: Text(
                "${formatCurrency(calculateTotalRevenue())}원",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              tileColor: Colors.blueGrey,
              title: const Text(
                "총 원가",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              trailing: Text(
                "${formatNumber(calculateTotalCost())}원",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              tileColor: Colors.blueGrey,
              title: const Text(
                "원가율",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              trailing: Text(
                "${formatCurrency(calculateTotalCostRate())}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 30,
            height: 50,
          )
        ],
      ),
    );
  }
}