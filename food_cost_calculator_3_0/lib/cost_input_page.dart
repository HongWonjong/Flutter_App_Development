import 'package:flutter/material.dart';
import '/cost_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CostInputPage extends StatefulWidget {
  const CostInputPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CostInputPageState createState() => _CostInputPageState();
}

class _CostInputPageState extends State<CostInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _quantityController = TextEditingController();
  final _foodPriceController = TextEditingController();
  bool _isFixedCost = true;
  final List<CostItem> _costList = [];

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    _foodPriceController.dispose();
    super.dispose();
  }

  void checkAndShowRatingDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int launchCount = prefs.getInt('launchCount') ?? 0;
    if (launchCount != 0 && launchCount % 5 == 0) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('쓸만 하신가요?'),
            content: const Text('원가계산기 어플이 마음에 드신다면 별점을 남겨주세요! 혹은 개선해야 할 부분도 알려주시면 감사하겠습니다.'),
            actions: <Widget>[
              TextButton(
                child: const Text('별점 주기'),
                onPressed: () {
                  // 앱 평가 페이지로 이동합니다.
                  launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=this.is.food_cost_calculator_3_0'));
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('그런거 안키워'),
                onPressed: () {
                  // 평가를 나중에 하려는 사용자를 위한 코드를 작성합니다.
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('원가 항목이 성공적으로 저장되었습니다.'),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    checkAndShowRatingDialog();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "원가 입력",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30.0),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  controller: _foodPriceController,
                  decoration: const InputDecoration(
                    labelText: "개당 판매가격",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "개당 가격을 입력하세요.";
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
                    labelText: "원가 항목",
                    hintText: "음식을 만드는데 무엇을 사용했나요?",
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "원가 항목명을 입력하세요.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                RadioListTile(
                  title: const Text('단위 고정원가(특정 음식 제조를 위한 고정비용)'),
                  value: true,
                  groupValue: _isFixedCost,
                  onChanged: (value) {
                    setState(() {
                      _isFixedCost = value ?? true;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('변동원가(식재료비 등 판매량 비례비용)'),
                  value: false,
                  groupValue: _isFixedCost,
                  onChanged: (value) {
                    setState(() {
                      _isFixedCost = value ?? true;
                    });
                  },
                ),
                TextFormField(
                  controller: _costController,
                  decoration: const InputDecoration(
                    labelText: "원가 항목 금액",
                    hintText: "변동원가라면 판매량에 곱해서 계산합니다.",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "금액을 입력하세요.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  onPressed: _addItem,
                  child: const Text(
                    "원가항목 저장",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
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
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 100),
                const Text(
                  'Copyright © 2023 by 홍원종',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
                const Text(
                  "문의사항은 리뷰로 남겨주세요.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
  final _foodTypeController = TextEditingController();
