import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../logic/cost_item.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../main.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../small one/custom_appbar.dart';
import 'package:food_cost_calculator_3_0/small one/review_please.dart';
import 'package:food_cost_calculator_3_0/small one/custom_drawer.dart';
import 'package:food_cost_calculator_3_0/logic/user_riverpod.dart';


class CostInputPage extends ConsumerStatefulWidget {
  const CostInputPage({Key? key}) : super(key: key);



  @override
  // ignore: library_private_types_in_public_api
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
  BannerAd? _bannerAd;


  @override

  void initState() {
    super.initState();
    _loadBannerAd();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final currentDisplayName = ref.watch(userDisplayNameProvider).value;
      if (currentDisplayName != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$currentDisplayName님, 환영합니다.'),
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('비로그인 사용자는 보고서 저장과 AI 분석을 사용할 수 없는 점 유의해주세요'),
          duration: Duration(milliseconds: 3000),
          behavior: SnackBarBehavior.floating,
        ));
      }
    });
  }


  void _loadBannerAd() {
    String adUnitId;

    if (kReleaseMode) {
      // 앱이 출시 모드일 때 실제 광고 ID를 사용합니다.
      adUnitId = Platform.isAndroid
          ? 'ca-app-pub-2047502466332917/1276029745'
          : 'YOUR_IOS_BANNER_AD_UNIT_ID';
    } else {
      // 앱이 테스트 모드일 때 테스트 광고 ID를 사용합니다.
      adUnitId = Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'YOUR_IOS_TEST_BANNER_AD_UNIT_ID';
    }

    const size = AdSize.banner;
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('BannerAd loaded.');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('BannerAd failed to load: $error');
        },
      ),
    );
    _bannerAd?.load();
  }


  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    _foodPriceController.dispose();
    _bannerAd?.dispose();
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.snackBarContent),
            duration: const Duration(milliseconds: 700), // 0.5초 지속 시간 설정
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    checkAndShowRatingDialog(context, incrementLaunchCount);


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(title: lang.costInputPage),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (_bannerAd != null)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    // Name input field
                    TextFormField(
                      controller: _foodTypeController,
                      decoration: InputDecoration(
                        labelText: lang.foodType,
                        labelStyle: const TextStyle(fontSize: 25.0),
                        border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang.foodTypeHint;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // Cost input field
                    TextFormField(
                      controller: _foodPriceController,
                      decoration: InputDecoration(
                        labelText: lang.unitPrice,
                        labelStyle: const TextStyle(fontSize: 25.0),
                        border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang.unitPriceHint;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: lang.salesVolume,
                        labelStyle: const TextStyle(fontSize: 25.0),
                        border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang.salesVolumeHint;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: lang.costItem,
                        labelStyle: const TextStyle(fontSize: 25.0),
                        border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang.costItemHint;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // Cost type radio buttons
                    ListTile(
                      title: Text(lang.fixedCost),
                      leading: Radio<bool>(
                        value: true,
                        groupValue: _isFixedCost,
                        onChanged: (bool? value) {
                          setState(() {
                            _isFixedCost = value ?? true;
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
                            _isFixedCost = value ?? true;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Food price input field
                    TextFormField(
                      controller: _costController,
                      decoration: InputDecoration(
                        labelText: lang.costItemPrice,
                        labelStyle: const TextStyle(fontSize: 25.0),
                        border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang.costItemPriceHint;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _addItem();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.white),  // Set background color to white
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 24.0,
                          ),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: const BorderSide(color: Colors.deepPurpleAccent, width: 2.0),  // Increase width to create a thicker border
                          ),
                        ),
                        overlayColor: MaterialStateProperty.all(Colors.deepPurpleAccent.withOpacity(0.1)),  // Add a overlay color to create a slight hover effect
                      ),
                      child: Text(
                        lang.saveCostItem,
                        style: const TextStyle(fontSize: 25.0, color: Colors.deepPurpleAccent),  // Set text color to deepPurpleAccent
                      ),
                    ),
                  ),
                  ElevatedButton(
                  onPressed: () {
                    if (_costList.isEmpty ||
                        _quantityController.text.isEmpty ||
                        _foodPriceController.text.isEmpty) {
                      // Show an alert dialog or a snack bar message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(lang.youShallNotPass),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
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
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),  // Set background color to white
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.deepPurpleAccent, width: 2.0),  // Increase width to create a thicker border
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.deepPurpleAccent.withOpacity(0.1)),  // Add a overlay color to create a slight hover effect
                  ),
                  child: Text(
                    lang.checkCalculation,
                    style: const TextStyle(fontSize: 25.0, color: Colors.deepPurpleAccent),  // Set text color to deepPurpleAccent
                  ),
                ),
                ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Text(lang.copyright),
        ),
      ),
    );
  }
}


