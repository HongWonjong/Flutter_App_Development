import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/component/app_bar.dart';
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
     // final user = ref.watch(uidProvider); // uidProvider를 감시하고 user 변수에 저장
   // final email = ref.watch(userEmailProvider).value;


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
              MediumButton(
                  buttonColor: AppColors.mainPageButtonColor,
                  onPressed: () {
                    NavigatorHelper.goToPage(context, CreateMemoPage());
                  },
                  buttonText: mainpage_lan.writeMemos,
                  textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.mainPageButtonTextColor)),
              const SizedBox(height: 16), // 버튼과 ListView 사이의 간격 조절
              MemoListWidget(),
            ],
          ),
        ),
      ),
    );

  }
}


