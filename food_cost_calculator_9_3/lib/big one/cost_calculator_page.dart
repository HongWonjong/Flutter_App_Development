import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../logic/cost_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../small one/custom_appbar.dart';
import 'package:food_cost_calculator_3_0/small one/menu_button.dart';
import 'package:food_cost_calculator_3_0/big%20one/upload_report.dart';
class CostCalculatorPage extends StatefulWidget {
  final List<CostItem> costList;
  final int quantity;
  final int foodPrice;

  const CostCalculatorPage({super.key,
    required this.costList,
    this.quantity = 0, // 기본값 설정
    this.foodPrice = 0, // 기본값 설정
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
    final lang = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: MyAppBar(title: lang.calculationPage_costCalculation),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ],
          ),
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
                          Text('${lang.calculationPage_salesVolume}: ${formatNumber(_costListByFoodType[foodType]!.first.quantity)} ${lang.calculationPage_name_of_unit}'),
                        ],
                      ),
                      children: [
                        ListTile(
                          title: Text("$foodType ${lang.calculationPage_revenueAndCostRate}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${lang.calculationPage_revenue} ${formatCurrency(_costListByFoodType[foodType]!.first.foodPrice * _costListByFoodType[foodType]!.first.quantity)} ${lang.calculationPage_name_of_currency}"),
                              Text("${lang.calculationPage_costRate} ${formatCurrency(calculateFoodCostRate(foodType))} %"),
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
                                costItem.isFixedCostPerUnit ? lang.calculationPage_fixedCost : lang.calculationPage_variableCost,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${formatNumber(costItem.unitCost)} ${lang.calculationPage_name_of_currency}",
                              ),
                              if(costItem.isFixedCostPerUnit) Text(
                                  "${lang.calculationPage_unitFixedCost}: ${formatCurrency(costItem.unitCost.toDouble() / _costListByFoodType[foodType]!.first.quantity)} ${lang.calculationPage_name_of_currency}"
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
                                    ? " ${formatNumber(costItem.unitCost)} ${lang.calculationPage_name_of_currency}"
                                    : " ${formatNumber(costItem.unitCost * _costListByFoodType[foodType]!.first.quantity)} ${lang.calculationPage_name_of_currency}",
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
              tileColor: Colors.deepPurpleAccent,
              title: Text(
                lang.calculationPage_totalRevenue,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              trailing: Text(
                "${formatCurrency(calculateTotalRevenue())} ${lang.calculationPage_name_of_currency}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              tileColor: Colors.deepPurpleAccent,
              title: Text(
                lang.calculationPage_totalCost,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              trailing: Text(
                "${formatNumber(calculateTotalCost())} ${lang.calculationPage_name_of_currency}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              tileColor: Colors.deepPurpleAccent,
              title: Text(
                lang.calculationPage_costRate,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              trailing: Text(
                "${formatCurrency(calculateTotalCostRate())} %",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              // 기존 원가 계산 위젯들...

              // 이 부분에 "보고서로 저장" 버튼 추가
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent, // primary sets the background color
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadReportPage(
                        fixedCostByFoodType: _fixedCostByFoodType,
                        variableCostByFoodType: _variableCostByFoodType,
                        costListByFoodType: _costListByFoodType,
                        totalRevenueByFoodType: _totalRevenueByFoodType,
                        profitByFoodType: _profitByFoodType,
                        totalCostRate: calculateTotalCostRate(),
                        totalRevenue: calculateTotalRevenue(),
                        totalCost: calculateTotalCost(),
                      ),
                    ),
                  );
                },
                child: const Text('계산 결과를 보고서로 저장',
                style: TextStyle(fontSize: 20),),
              ),
            ],
          )

        ],
      ),
    );
  }
}