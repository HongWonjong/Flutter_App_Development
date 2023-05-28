import 'package:flutter/material.dart';
import '/cost_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            title: Text(
                AppLocalizations.of(context)!.dialogTitle),
                content: Text(
                AppLocalizations.of(context)!.dialogContent),
            actions: <Widget>[
              TextButton(
                child: Text(
                    AppLocalizations.of(context)!.giveStar),
                onPressed: () {
                  launchUrl(Uri.parse(
                      'https://play.google.com/store/apps/details?id=this.is.food_cost_calculator_3_0'));
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                    AppLocalizations.of(context)!.notNow),
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
            content: Text(
                AppLocalizations.of(context)!.snackBarContent),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    checkAndShowRatingDialog();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          lang.costInputPage,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30.0),
        ),
        backgroundColor: Colors.blueGrey,
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'English') {
                ref.watch(languageProvider.notifier).switchToEnglish();
              } else if (value == 'Korean') {
                ref.watch(languageProvider.notifier).switchToKorean();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'English',
                  child: Text('English'),
                ),
                const PopupMenuItem<String>(
                  value: 'Korean',
                  child: Text('Korean'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    // Name input field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: lang.foodType,
                        labelStyle: const TextStyle(fontSize: 25.0),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang.foodTypeHint;
                        }
                        return null;
                      },
                    ),
                    // Cost input field
                    TextFormField(
                      controller: _costController,
                      decoration: InputDecoration(
                        labelText: lang.costItemPrice,
                        labelStyle: const TextStyle(fontSize: 25.0),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang.costItemHint;
                        }
                        return null;
                      },
                    ),
                    // Cost type radio buttons
                    ListTile(
                      title: Text(lang.fixedCost),
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
                      title: Text(lang.variableCost),
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
                        labelText: lang.salesVolume,
                        labelStyle: const TextStyle(fontSize: 25.0),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang.salesVolumeHint;
                        }
                        return null;
                      },
                    ),
                    // Food price input field
                    TextFormField(
                      controller: _foodPriceController,
                      decoration: InputDecoration(
                        labelText: lang.unitPrice,
                        labelStyle: const TextStyle(fontSize: 25.0),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang.unitPriceHint;
                        }
                        return null;
                      },
                    ),
                    // Food type input field
                    TextFormField(
                      controller: _foodTypeController,
                      decoration: InputDecoration(
                        labelText: lang.foodType,
                        labelStyle: const TextStyle(fontSize: 25.0),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang.foodTypeHint;
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
                        child: Text(lang.saveCostItem),
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
                    subtitle: Text(
                        '${_costList[index].unitCost} per ${_costList[index]
                            .quantity}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
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


