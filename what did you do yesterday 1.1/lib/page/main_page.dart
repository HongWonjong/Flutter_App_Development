import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/component/app_bar.dart';
import 'package:freedomcompass/page/setting_page.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/component/sized_box.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/component/memo_list.dart';
import 'package:freedomcompass/function/navigator.dart';
import 'create_memo_page.dart';


class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const CustomAppBar(
        titleText: mainpage_lan.mainPageTitle,
      ),
      body: Container(
        color: AppColors.centerColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const AdaptiveSizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MediumButton(
                      buttonColor: AppColors.mainPageButtonColor,
                      onPressed: () {
                        NavigatorHelper.goToPage(context, CreateMemoPage());
                      },
                      buttonText: mainpage_lan.writeMemos,
                      textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.mainPageButtonTextColor)),
                  IconButton(
                    onPressed: () {
                      NavigatorHelper.goToPage(context, const SettingPage());
                    },
                    icon: const Icon(Icons.settings),
                    iconSize: screenWidth * 0.15,
                    color: AppColors.mainPageButtonTextColor,
                  ),
                ],
              ),
              const MemoListWidget(),
            ],
          ),
        ),
      ),
    );
  }
}


