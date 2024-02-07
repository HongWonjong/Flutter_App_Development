// custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:website/style/language.dart';
import 'package:website/style/media_query_custom.dart';
import 'package:website/function/google_auth.dart';
import 'package:website/function/upload_user_basic_data.dart';
import 'package:website/function/riverpod_setting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginStatus = ref.watch(googleSignInProvider);
    final email = ref.watch(userEmailProvider).value;
    final gp = ref.watch(userGPProvider).value;
    AuthFunctions authFunctions = AuthFunctions();

    return AppBar(
      title: const Text(mainpage_lan.appBarTitle),
      backgroundColor: Colors.blue,
      actions: <Widget>[
        // 예시: 사용자가 로그인되어 있는 경우에만 텍스트 표시
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: loginStatus != null
              ? [
            Text('환영합니다 $email 님'),
            Text("현재 GeminiPoint: $gp"),
          ]
              : <Widget>[], // 혹은 빈 리스트를 사용하여 아무것도 표시하지 않음
        ),
        IconButton(
          icon: const Icon(Icons.account_circle),
          iconSize: MQSize.getDetailHeight2(context),
          onPressed: () async {
            UserDataUpload userDataUpload = UserDataUpload();
            userDataUpload.addUserToFirestore();
            UserDataUpload userDataUpload2 = UserDataUpload();
            userDataUpload2.checkAndAddDefaultUserData();
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_outlined),
          iconSize: MQSize.getDetailHeight2(context),
          onPressed: () {
            authFunctions.signOut();
          },
        ),
      ],
    );
  }
}

