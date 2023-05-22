import 'package:flutter/material.dart';
import '/cost_item.dart';

class CostInputPage extends StatefulWidget {
  const CostInputPage({super.key});

  @override
  _CostInputPageState createState() => _CostInputPageState();
}

class _CostInputPageState extends State<CostInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _quantityController = TextEditingController();
  final _foodPriceController = TextEditingController();
  final _foodTypeController = TextEditingController();
  bool _isFixedCost = true;
  final List<CostItem> _costList = [];

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
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
            isFixedCostPerUnit: _isFixedCost,
            unitCost: int.parse(_costController.text),
            foodType: _foodTypeController.text,
            quantity: int.parse(_quantityController.text),
            foodPrice: double.parse(_foodPriceController.text),
          ),
        );

        _nameController.clear();
        _costController.clear();
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
                            title: const Text('단위 고정원가(특정 음식 제조를 위한 고정비용)'),
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
                      controller: _costController,
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
                        SizedBox(height: 100),
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