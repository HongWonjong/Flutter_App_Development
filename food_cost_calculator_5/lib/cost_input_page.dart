import 'package:flutter/material.dart';
import '/cost_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/language.dart';

class CostInputPage extends ConsumerStatefulWidget {
  const CostInputPage({Key? key}) : super(key: key);

  @override
  _CostInputPageState createState() => _CostInputPageState();
}

class _CostInputPageState extends ConsumerState<CostInputPage> {
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
    _foodPriceController.dispose();
    super.dispose();
  }

  void checkAndShowRatingDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int launchCount = prefs.getInt('launchCount') ?? 0;
    if (launchCount != 0 && launchCount % 5 == 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(ref.watch(languageProvider.state)['rating_dialog_title']),
            content: Text(ref.watch(languageProvider.state)['rating_dialog_content']),
            actions: <Widget>[
              TextButton(
                child: Text(ref.watch(languageProvider.state)['rating_dialog_option_rate']),
                onPressed: () {
                  launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=this.is.food_cost_calculator_3_0'));
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(ref.watch(languageProvider.state)['rating_dialog_option_later']),
                onPressed: () {
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
          SnackBar(
            content: Text(ref.watch(languageProvider.state)['snackbar_text']),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    checkAndShowRatingDialog();

    final lang = ref.watch(languageProvider.state);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          lang['input_title'],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30.0),
        ),
        backgroundColor: Colors.blueGrey,
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              ref.read(languageProvider.state.notifier).change(value);
            },
            itemBuilder: (BuildContext context) {
              return ['en', 'ko'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    // Name input field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: lang['label_name'],
                        labelStyle: TextStyle(fontSize: 25.0),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang['validator_message'];
                        }
                        return null;
                      },
                    ),
                    // Cost input field
                    TextFormField(
                      controller: _costController,
                      decoration: InputDecoration(
                        labelText: lang['label_cost'],
                        labelStyle: TextStyle(fontSize: 25.0),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang['validator_message'];
                        }
                        return null;
                      },
                    ),
                    // Cost type radio buttons
                    ListTile(
                      title: const Text('Fixed Cost'),
                      leading: Radio<bool>(
                        value: true,
                        groupValue: _isFixedCost,
                        onChanged: (bool? value) {
                          setState(() {
                            _isFixedCost = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Variable Cost'),
                      leading: Radio<bool>(
                        value: false,
                        groupValue: _isFixedCost,
                        onChanged: (bool? value) {
                          setState(() {
                            _isFixedCost = value!;
                          });
                        },
                      ),
                    ),
                    // Quantity input field
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: lang['label_quantity'],
                        labelStyle: TextStyle(fontSize: 25.0),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang['validator_message'];
                        }
                        return null;
                      },
                    ),
                    // Food price input field
                    TextFormField(
                      controller: _foodPriceController,
                      decoration: InputDecoration(
                        labelText: lang['label_food_price'],
                        labelStyle: TextStyle(fontSize: 25.0),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang['validator_message'];
                        }
                        return null;
                      },
                    ),
                    // Food type input field
                    TextFormField(
                      controller: _foodTypeController,
                      decoration: InputDecoration(
                        labelText: lang['label_food_type'],
                        labelStyle: TextStyle(fontSize: 25.0),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang['validator_message'];
                        }
                        return null;
                      },
                    ),
                    // Add item button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _addItem();
                        },
                        child: Text(lang['add_item_button_text']),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _costList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_costList[index].name),
                    subtitle: Text('${_costList[index].unitCost} per ${_costList[index].quantity}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _costList.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void launchUrl(Uri url) async {
  if (await canLaunch(url.toString())) {
    await launch(url.toString());
  } else {
    throw 'Could not launch $url';
  }
}

