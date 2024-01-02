import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/bottom_bar.dart';
import 'package:freedomcompass/style/app_bar.dart';
import 'package:freedomcompass/function/osm_map.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/style/sized_box.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/rriverpod/user_riverpod.dart';
import 'package:freedomcompass/rriverpod/map_controller_riverpod.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
     // final user = ref.watch(uidProvider); // uidProvider를 감시하고 user 변수에 저장
    final email = ref.watch(userEmailProvider).value;


    double screenWidth = MediaQuery.of(context).size.width;
    double targetWidth = screenWidth * 0.9;

    return Scaffold(
      appBar: const CustomAppBar(
        titleText: mainpage_lan.mainPageTitle,
      ),
      body: Container(
        color: AppColors.centerColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'User Email: $email', // 가져온 사용자의 UID를 출력
                style: AdaptiveText.mediumTextStyle(context),
              ),
              MediumButton(
                onPressed: () {
                   MapWidget();
                },
                buttonText: mainpage_lan.setToMyPosition,
                buttonColor: AppColors.buttonColor,
                textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.buttonTextColor),
              ),
              const AdaptiveSizedBox(),
              SizedBox(
                width: targetWidth,
                height: targetWidth * 0.9,
                child: MapWidget(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Material(
        child: CustomBottomBar(),
      ),
    );
  }
}


