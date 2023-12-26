import 'package:flutter/material.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/bottom_bar.dart';
import 'package:freedomcompass/style/text_style.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mainpage_lan.mainPageTitle,
        style: AdaptiveText.titleTextStyle(context,color: Colors.black)),

      ),
      body: const Center(
        child: Text(mainpage_lan.centerMessage),
      ),
      bottomNavigationBar: const Material(
        child: BottomBar(),
      ),
    );
  }
}
