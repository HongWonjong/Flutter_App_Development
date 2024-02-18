import 'package:flutter/material.dart';
import 'package:website/style/language.dart';
import 'package:website/style/media_query_custom.dart';
import 'package:website/function/google_auth.dart';
import 'package:website/function/upload_user_basic_data.dart';
import 'package:website/function/riverpod_setting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website/style/color.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';





class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final email = ref.watch(userEmailProvider).value;
    final gp = ref.watch(userGPProvider).value;
    AuthFunctions authFunctions = AuthFunctions();

    final isLoggedIn = authState.maybeWhen(
      data: (user) => user != null, // User 객체가 null이 아니면 로그인한 것으로 간주
      orElse: () => false, // 그 외의 경우에는 로그인하지 않은 것으로 간주
    );

    return Container(
      decoration:   BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.bodyGradationLeft,
            AppColors.bodyGradationRight,
          ],
        ),
      ),
      child: AppBar(
        title: Text(MainPageLan.appBarTitle, style: TextStyle(fontSize: MQSize.getDetailWidth1(context)),),
        backgroundColor: AppColors.appBarColor,
        centerTitle: true,
        actions: <Widget>[
          // 예시: 사용자가 로그인되어 있는 경우에만 텍스트 표시
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: isLoggedIn
                ? [
              Text('$email', style: TextStyle(fontSize: MQSize.getDetailWidth01(context)),),
              Text("GeminiPoint: $gp", style: TextStyle(fontSize: MQSize.getDetailWidth01(context)),),
            ]
                : [
              const Text(MainPageLan.clickGoogleIcon)
            ], // 혹은 빈 리스트를 사용하여 아무것도 표시하지 않음
          ),
          IconButton(
            icon: Image.asset(
              'lib/images/googleLogin.png',
              height: MQSize.getDetailHeight2(context),
            ),
            onPressed: () async {
              AuthFunctions auth = AuthFunctions();
              auth.signInWithGoogle(ref);
              UserDataUpload userDataUpload = UserDataUpload();
              userDataUpload.addUserToFirestore();
              UserDataUpload userDataUpload2 = UserDataUpload();
              userDataUpload2.checkAndAddDefaultUserData();
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout_outlined, color: AppColors.whiteTextColor),
            iconSize: MQSize.getDetailHeight2(context),
            onPressed: () {
              authFunctions.signOut(ref);
              DefaultCacheManager().emptyCache();
              },
          ),
        ],
      ),
    );
  }
}

