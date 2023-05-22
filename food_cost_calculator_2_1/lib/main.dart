import 'package:intl/intl.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MaterialApp(
    title: "원가 계산기",
    initialRoute: "/",
    theme: ThemeData(
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(secondary: Colors.orange),
    ),
    routes: {
      "/": (context) => CostInputPage(),
      "/calculate": (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return CostCalculatePage(costList: args['costList'], totalQuantity: args['quantity']);
      },
    },
  ));
}



class CostInputPage extends StatefulWidget {
  @override
  _CostInputPageState createState() => _CostInputPageState();
}

class _CostInputPageState extends State<CostInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _foodTypeController = TextEditingController(); // 추가
  bool _isFixedCost = true;
  final List<CostItem> _costList = [];
  int totalQuantity = 0; // 글로벌 변수 선언

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
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

        _amountController.clear();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("원가 입력",
          style: TextStyle(color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30.0),),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: " 원가 항목명",
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "원가 항목명을 입력하세요.";
                  }
                  return null;
                },
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬 추가
                children: [
                  Radio(
                    value: true,
                    groupValue: _isFixedCost,
                    onChanged: (value) {
                      setState(() {
                        _isFixedCost = value ?? true;
                      });
                    },
                  ),
                  const Text("고정원가"),
                  Radio(
                    value: false,
                    groupValue: _isFixedCost,
                    onChanged: (value) {
                      setState(() {
                        _isFixedCost = value ?? true;
                      });
                    },
                  ),
                  const Text("변동원가"),
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
              Container(
                width: 50,
                height: 30,

              ),
              TextFormField(
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
              ElevatedButton(
                onPressed: _addItem,
                child: const Text("입력"),
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: " 판매량",
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "판매량을 입력하세요.";
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_quantityController.text.isNotEmpty) {
                    totalQuantity = int.parse(_quantityController.text); // totalQuantity 변수에 값을 할당해줌
                    Navigator.pushNamed(
                      context,
                      '/calculate',
                      arguments: {'costList': _costList, 'totalQuantity': totalQuantity},
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("판매량을 입력하세요.")),
                    );
                  }
                },
                child: const Text("원가 계산하기"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class CostCalculatePage extends StatefulWidget {
  final List<CostItem> costList;
  final int totalQuantity;

  const CostCalculatePage({
    Key? key,
    required this.costList,
    required this.totalQuantity,
  }) : super(key: key);

  @override
  _CostCalculatePageState createState() => _CostCalculatePageState();
}


class _CostCalculatePageState extends State<CostCalculatePage> {
  final Map<String, int> _fixedCostByFoodType = {};
  final Map<String, int> _variableCostByFoodType = {};
  final Map<String, List<CostItem>> _costListByFoodType = {};
  @override
  void initState() {
    super.initState();
    _calculateCostsByFoodType();
  }
  int get totalQuantity => widget.totalQuantity; // totalQuantity 변수 추가

  List<CostItem> get _costList => widget.costList;



  ListTile _buildCostItemWidgets(CostItem costItem) {

    int totalCost = costItem.isFixedCost ? costItem.amount : costItem.amount * widget.totalQuantity;
    double unitCost = totalCost / widget.totalQuantity;
    double costRate = unitCost * 100;
    return ListTile(
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
          Text("${formatNumber(costItem.amount)}원"),
        ],
      ),
    );
  }

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
    for (var costItem in widget.costList) {
      if (costItem.isFixedCost) {
        _fixedCostByFoodType[costItem.foodType] =
            (_fixedCostByFoodType[costItem.foodType] ?? 0) + costItem.amount;
      } else {
        _variableCostByFoodType[costItem.foodType] =
            (_variableCostByFoodType[costItem.foodType] ?? 0) + costItem.amount * widget.totalQuantity;
      }
      if (_costListByFoodType[costItem.foodType] == null) {
        _costListByFoodType[costItem.foodType] = [];
      }
      _costListByFoodType[costItem.foodType]!.add(costItem);
    }
  }


  double calculateCostRate() {
    int totalFixedCost = 0;
    int totalVariableCost = 0;
    for (var costItem in widget.costList) {
      if (costItem.isFixedCost) {
        totalFixedCost += costItem.amount;
      } else {
        totalVariableCost += costItem.amount * widget.totalQuantity;
      }
    }
    int totalCost = totalFixedCost + totalVariableCost;
    double unitCost = totalCost / widget.totalQuantity;
    return unitCost / widget.totalQuantity * 100;
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
    return totalFixedCost + totalVariableCost * widget.totalQuantity;
  }



  String formatNumber(int value) {
    final formatter = NumberFormat("#,##0");
    return formatter.format(value);
  }

  String formatCurrency(double value) {
    final formatter = NumberFormat("#,##0.00");
    return formatter.format(value);
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
    int totalCost = totalFixedCost + totalVariableCost * totalQuantity; // totalQuantity 변수 사용
    return totalCost / totalQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "원가 계산",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _costListByFoodType.length,
              itemBuilder: (context, index) {
                final foodType = _costListByFoodType.keys.elementAt(index);
                final costItemList = _costListByFoodType[foodType] ?? []; // 예외 처리 추가
                return ExpansionTile(
                  title: Text(foodType),
                  children: [
                    ...costItemList
                        .map(_buildCostItemWidgets)
                        .toList(),
                    ListTile(
                      title: const Text(
                        "총 원가(해당 음식)",
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      trailing: Text(
                        "${formatNumber((_fixedCostByFoodType[foodType] ?? 0) + (_variableCostByFoodType[foodType] ?? 0))}원",
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        "개당 원가(해당 음식)",
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      trailing: Text(
                        "${formatCurrency((_fixedCostByFoodType[foodType] ?? 0) / widget.totalQuantity + (_variableCostByFoodType[foodType] ?? 0) / widget.totalQuantity)
                        }원",
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        "원가율(해당 음식)",
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      trailing: Text(
                        "${formatCurrency(((_fixedCostByFoodType[foodType] ?? 0) + (_variableCostByFoodType[foodType] ?? 0)) / widget.totalQuantity / widget.totalQuantity * 100)}%",
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                );

              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text(
                "총 원가(전체 합산)",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              trailing: Text(
                "${formatNumber(calculateTotalCost())}원",
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text(
                "개당 원가(전체 합산)",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              trailing: Text(
                "${formatCurrency((_fixedCostByFoodType.values.reduce((a, b) => a + b) / totalQuantity) + (_variableCostByFoodType.values.reduce((a, b) => a + b) / totalQuantity))}원",
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text(
                "원가율(전체 합산)",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              trailing: Text(
                "${formatCurrency((_fixedCostByFoodType.values.reduce((a, b) => a + b) + _variableCostByFoodType.values.reduce((a, b) => a + b)) / totalQuantity / widget.totalQuantity * 100)}%",
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Container(
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
  final String foodType; // 음식 종류 추가

  CostItem({
    required this.name,
    required this.isFixedCost,
    required this.amount,
    required this.foodType, // 음식 종류 추가
  });
}