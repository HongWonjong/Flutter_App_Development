// custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:website/style/language.dart';
import 'package:website/style/media_query_custom.dart';
import 'package:website/function/google_auth.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
   CustomAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize =>  const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(mainpage_lan.appBarTitle),
      backgroundColor: Colors.blue,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.person_add),
          iconSize: MQSize.getDetailHeight2(context),
          onPressed: () {
            AuthFunctions.signInWithGoogle();
          },
        ),
        IconButton(
          icon: const Icon(Icons.login),
          iconSize: MQSize.getDetailHeight2(context),
          onPressed: () {
            // 로그인 버튼을 눌렀을 때의 동작 추가
          },
        ),
      ],
    );
  }
}

