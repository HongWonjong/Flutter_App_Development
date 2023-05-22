// ignore_for_file: library_private_types_in_public_api, duplicate_ignore

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: "원가 계산기",
    initialRoute: "/",
    theme: ThemeData(
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey).copyWith(secondary: Colors.orange),
    ),
    routes: {
      "/": (context) => const CostInputPage(),
      "/calculate": (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return CostCalculatePage(costList: args['costList'], quantity: args['quantity'], foodPrice: args['itemPrice']);
      },
    },
  ));
}


class CostInputPage extends StatefulWidget {
  const CostInputPage({super.key});

  @override
  _CostInputPageState createState() => _CostInputPageState();
}

class _CostInputPageState extends State<CostInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _foodPriceController = TextEditingController();
  final _foodTypeController = TextEditingController(); // 추가
  bool _isFixedCost = true;
  final List<CostItem> _costList = [];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    _foodPriceController.dispose(); // 추가
    super.dispose();
  }
  void _addItem() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _costList.add(
          CostItem(
            name: _nameController.text,
            isFixedCost: _isFixedCost,
            amount: int.parse(_amountController.text),
            foodType: _foodTypeController.text,
          ),
        );

        _nameController.clear();
        _amountController.clear();
      });
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("원가 입력",
            style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30.0),),
          backgroundColor: Colors.blueGrey,
        ),
        body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                    children: [
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _foodTypeController,
                        decoration: const InputDecoration(
                          labelText: "음식 종류",
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "음식 종류를 입력하세요.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _foodPriceController, // 추가
                        decoration: const InputDecoration(
                          labelText: " 개당 판매가격", // 추가
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "개당 가격을 입력하세요."; // 수정
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: "음식 판매량",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "판매량을 입력하세요.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: " 원가 항목",
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "원가 항목명을 입력하세요.";
                          }
                          return null;
                        },
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: RadioListTile(
                              title: const Text('고정원가(건물 임차료 등 고정발생비용)'),
                              value: true,
                              groupValue: _isFixedCost,
                              onChanged: (value) {
                                setState(() {
                                  _isFixedCost = value ?? true;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              title: const Text('변동원가(식재료비 등 판매량 비례비용)'),
                              value: false,
                              groupValue: _isFixedCost,
                              onChanged: (value) {
                                setState(() {
                                  _isFixedCost = value ?? true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),


                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: " 원가 항목 금액",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "금액을 입력하세요.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        width: 50,
                        height: 30,

                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey, // 배경색을 빨간색으로 설정
                          ),
                        onPressed: _addItem,
                        child: const Text(
                          "원가항목 저장",
                          style:
                          TextStyle(fontSize: 20,
                          color: Colors.white))),
                      const SizedBox(height: 10),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey, // 배경색을 빨간색으로 설정
                        ),
                        onPressed: () {
                          if (_quantityController.text.isNotEmpty) {
                            Navigator.pushNamed(
                              context,
                              "/calculate",
                              arguments: {
                                'costList': _costList,
                                'quantity': int.parse(_quantityController.text),
                                'itemPrice': int.parse(_foodPriceController.text),
                              },
                            );
                          }
                        },
                        child: const Text(
                          "계산결과 확인",
                          style: TextStyle(fontSize: 20,
                          color: Colors.white),),


                      ),
                      Column(
                        children: const [
                          // 기타 위젯들
                          SizedBox(height: 110),
                          Text(
                            'Copyright © 2023 by 홍원종',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                          Text("문의사항은 wonhong1996@naver.com",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                          ))
                        ],
                      )
                    ]
                ),
            )
        )

    );
  }
}

class CostCalculatePage extends StatefulWidget {
  final List<CostItem> costList;
  final int quantity;
  final int foodPrice;

  const CostCalculatePage({super.key,
    required this.costList,
    required this.quantity,
    required this.foodPrice,
  });

  @override
  _CostCalculatePageState createState() => _CostCalculatePageState();
}
class _CostCalculatePageState extends State<CostCalculatePage> {
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
      if (costItem.isFixedCost) {
        _fixedCostByFoodType[costItem.foodType] =
            (_fixedCostByFoodType[costItem.foodType] ?? 0) + costItem.amount;
      } else {
        _variableCostByFoodType[costItem.foodType] =
            (_variableCostByFoodType[costItem.foodType] ?? 0) + costItem.amount;
      }

      if (_costListByFoodType[costItem.foodType] == null) {
        _costListByFoodType[costItem.foodType] = [];
      }
      _costListByFoodType[costItem.foodType]!.add(costItem);
    }

    for (var foodType in _costListByFoodType.keys) {
      int totalVariableCost = _variableCostByFoodType[foodType] ?? 0;
      for (var costItem in _costListByFoodType[foodType]!) {
        if (!costItem.isFixedCost) {
          totalVariableCost += costItem.amount;
        }
      }
      _variableCostByFoodType[foodType] = totalVariableCost;

      int totalRevenue = widget.quantity * widget.foodPrice;
      _totalRevenueByFoodType[foodType] = totalRevenue;

      int totalCost = (_fixedCostByFoodType[foodType] ?? 0) + (totalVariableCost * widget.quantity);
      int totalProfit = totalRevenue - totalCost;
      _profitByFoodType[foodType] = totalProfit;
    }
  }





  double calculateCostRate() {
    double unitCost = calculateUnitCost();
    return unitCost / widget.foodPrice * 100;
  }

  int calculateTotalCost() {
    int totalFixedCost = 0;
    int totalVariableCost = 0;
    for (var costItem in widget.costList) {
      if (costItem.isFixedCost) {
        totalFixedCost += costItem.amount;
      } else {
        totalVariableCost += costItem.amount;
      }
    }
    return totalFixedCost + totalVariableCost * widget.quantity;
  }


  String formatNumber(int value) {
    final formatter = NumberFormat("#,##0");
    return formatter.format(value);
  }

  String formatCurrency(double value) {
    final formatter = NumberFormat("#,##0.00");
    return formatter.format(value / quantity);
  }


  double calculateUnitCost() {
    int totalFixedCost = 0;
    int totalVariableCost = 0;
    for (var costItem in widget.costList) {
      if (costItem.isFixedCost) {
        totalFixedCost += costItem.amount;
      } else {
        totalVariableCost += costItem.amount;
      }
    }
    int totalCost = totalFixedCost + totalVariableCost * quantity;
    return totalCost * 1.0;
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
            child: ListView.builder(
              itemCount: _costListByFoodType.length,
              itemBuilder: (context, index) {
                final foodType = _costListByFoodType.keys.elementAt(index);
                final costItemList = _costListByFoodType[foodType]!;
                return ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(foodType),
                      Text('판매량: $quantity개'),
                    ],
                  ),
                  children: costItemList.map(
                        (costItem) => ListTile(
                      title: Text(costItem.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            costItem.isFixedCost ? "고정원가" : "변동원가",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${formatNumber(costItem.amount)}원",
                          ),
                          if(costItem.isFixedCost) Text(
                            "개당 고정원가: ${formatCurrency(costItem.amount * 1.0)}원",
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
                            costItem.isFixedCost
                                ? "합계: ${formatNumber(costItem.amount)}원"
                                : "합계: ${formatNumber(costItem.amount * widget.quantity)}원",
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                );
              },
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
                "개당 원가",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18
                ),
              ),
              trailing: Text(
                "${formatCurrency(calculateUnitCost())}원",
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
                "${formatCurrency(calculateCostRate())}%",
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



class CostItem {
  final String name;
  final bool isFixedCost;
  final int amount;
  final String foodType;

  CostItem({
    required this.name,
    required this.isFixedCost,
    required this.amount,
    required this.foodType,
  });
}
