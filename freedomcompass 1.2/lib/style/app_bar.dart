import 'package:flutter/material.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/text_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(mainpage_lan.mainPageTitle,
          style: AdaptiveText.titleTextStyle(context, color: Colors.black)),
    );
  }
}

