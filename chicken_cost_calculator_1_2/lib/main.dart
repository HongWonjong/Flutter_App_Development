import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: "원가 계산기",
    initialRoute: "/",
    theme: ThemeData(
      primarySwatch: Colors.green,
      accentColor: Colors.orange,
    ),
    routes: {
      "/": (context) => CostInputPage(),
      "/calculate": (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return CostCalculatePage(costList: args['costList'], quantity: args['quantity'], chickenPrice: args['chickenPrice']);
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
  final _chickenPriceController = TextEditingController();
  bool _isFixedCost = true;
  List<CostItem> _costList = [];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    _chickenPriceController.dispose(); // 추가
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
      appBar: AppBar(
        title: Text("원가 입력",
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
                controller: _nameController,
                decoration: InputDecoration(
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
                children: [
                  Radio(
                    value: true,
                    groupValue: _isFixedCost,                onChanged: (value) {
                    setState(() {
                      _isFixedCost = value ?? true;
                    });
                  },
                  ),
                  Text("고정원가(ex: 건물 임차료, 한번 입력하면 다른 음식에도 판매량에 따라 분배됩니다.)"),
                  Radio(
                    value: false,
                    groupValue: _isFixedCost,
                    onChanged: (value) {
                      setState(() {
                        _isFixedCost = value ?? true;
                      });
                    },
                  ),
                  Text("변동원가(ex: 재료비, 포장비)"),
                ],
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
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
                controller: _chickenPriceController, // 추가
                decoration: InputDecoration(
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
                child: Text("입력"),
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
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
                    Navigator.pushNamed(
                      context,
                      "/calculate",
                      arguments: {
                        'costList': _costList,
                        'quantity': int.parse(_quantityController.text),
                        'chickenPrice': int.parse(_chickenPriceController.text), // 추가
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("판매량을 입력하세요.")),
                    );
                  }
                },
                child: Text("원가 계산하기"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class CostCalculatePage extends StatelessWidget {
  final List<CostItem> costList;
  final int quantity;
  final int chickenPrice;

  CostCalculatePage({required this.costList, required this.quantity, required this.chickenPrice});

  double calculateCostRate() {
    double unitCost = calculateUnitCost();
    return unitCost / chickenPrice * 100;
  }


  int calculateTotalCost() {
    int totalFixedCost = 0;
    int totalVariableCost = 0;
    for (var costItem in costList) {
      if (costItem.isFixedCost) {
        totalFixedCost += costItem.amount;
      } else {
        totalVariableCost += costItem.amount;
      }
    }
    return totalFixedCost + totalVariableCost * quantity;
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
    for (var costItem in costList) {
      if (costItem.isFixedCost) {
        totalFixedCost += costItem.amount;
      } else {
        totalVariableCost += costItem.amount;
      }
    }
    int totalCost = totalFixedCost + totalVariableCost * quantity;
    return totalCost / quantity;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("원가 계산",
          style: TextStyle(color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 30.0),),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: costList.length,
              itemBuilder: (context, index) {
                final costItem = costList[index];
                return Card(
                  child: ListTile(
                    title: Text(costItem.name),
                    subtitle: Text(costItem.isFixedCost
                        ? "고정원가: ${costItem.amount}원"
                        : "변동원가: ${costItem.amount}원"),
                    trailing: Text(costItem.isFixedCost
                        ? "${formatNumber(costItem.amount)}원"
                        : "${formatNumber(costItem.amount * quantity)}원"),

                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text(
                "총 원가",
                style: TextStyle(
                  color: Colors.blue, // 빨간색
                ),
              ),
              trailing: Text(
                "${formatNumber(calculateTotalCost())}원",
                style: TextStyle(
                  color: Colors.blue, // 빨간색
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(
                "개당 원가",
                style: TextStyle(
                  color: Colors.blue, // 파란색
                ),
              ),
              trailing: Text(
                "${formatCurrency(calculateUnitCost())}원",
                style: TextStyle(
                  color: Colors.blue, // 파란색
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(
                "원가율",
                style: TextStyle(
                  color: Colors.blue, // 파란색
                ),
              ),
              trailing: Text(
                "${formatCurrency(calculateCostRate())}%",
                style: TextStyle(
                  color: Colors.blue, // 파란색
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

  CostItem({
    required this.name,
    required this.isFixedCost,
    required this.amount,
  });
}