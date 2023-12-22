import 'package:flutter/material.dart';
import 'package:freedomcompass/l10n/language.dart';


class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(mainpage_lan.mainPageTitle),
      ),
      body: const Center(
        child: Text(mainpage_lan.centerMessage),
      ),
    );
  }
}
