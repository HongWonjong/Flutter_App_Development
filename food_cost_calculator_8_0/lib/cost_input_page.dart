import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/cost_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'main.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'custom_appbar.dart';

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

  void checkAndShowRatingDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int launchCount = prefs.getInt('launchCount') ?? 0;
    if (launchCount != 0 && launchCount % 200 == 0) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.dialogTitle),
            content: Text(AppLocalizations.of(context)!.dialogContent),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.giveStar),
                onPressed: () {
                  launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=this.is.food_cost_calculator_3_0'));
                  Navigator.of(context).pop();
                  incrementLaunchCount(); // 리뷰를 달았으므로 카운트 증가
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.notNow),
                onPressed: () {
                  incrementLaunchCount(); // 리뷰를 달지 않고도 카운트 증가
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      incrementLaunchCount(); // 화면을 나가서 리뷰를 달지 않았지만 카운트 증가
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
            content: Text(AppLocalizations.of(context)!.snackBarContent),
            duration: const Duration(milliseconds: 700), // 0.5초 지속 시간 설정
          ),
        );
      });
    }
  }
  final languages = <Map<String, String>>[
    {'value': 'en', 'name': 'English'},
    {'value': 'ko', 'name': 'Korean'},
    {'value': 'zh', 'name': 'Mandarin'},
    {'value': 'es', 'name': 'Spanish'},
    {'value': 'ja', 'name': 'Japanese'},
    {'value': 'ru', 'name': 'Russian'},
    {'value': 'pt', 'name': 'Portuguese'},
    {'value': 'de', 'name': 'German'},
    {'value': 'ar', 'name': 'Arabic'},
    {'value': 'hi', 'name': 'Hindi'},
    {'value': 'bn', 'name': 'Bengali'},
    {'value': 'fr', 'name': 'French'},
    {'value': 'it', 'name': 'Italian'},
    {'value': 'nl', 'name': 'Dutch'},
  ];

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    checkAndShowRatingDialog();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(title: lang.costInputPage),

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
                        border: const OutlineInputBorder(),
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: lang.costItem,
                        labelStyle: const TextStyle(fontSize: 25.0),
                        border: const OutlineInputBorder(),
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
                        border: const OutlineInputBorder(),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        onPressed: () {
                          _addItem();
                        },
                        child: Text(lang.saveCostItem,
                            style: const TextStyle(fontSize: 25),),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
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
                      child: Text(
                        lang.checkCalculation,
                        style: const TextStyle(fontSize: 25),
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


