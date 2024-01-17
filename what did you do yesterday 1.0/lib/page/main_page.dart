import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/app_bar.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/style/sized_box.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/rriverpod/user_riverpod.dart';
import 'package:freedomcompass/style/text_style.dart';


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
                    // elevated button
                  },
                  buttonText: mainpage_lan.writeMemos,
                  textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.mainPageButtonTextColor)),
              const SizedBox(height: 16), // 버튼과 ListView 사이의 간격 조절
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  padding: EdgeInsets.all(16.0), // 패딩을 설정하세요
                  color: AppColors.listViewBackgroundColor, // 배경색을 설정하세요
                  child: ListView.builder(
                    itemCount: 10, // 메모 아이템 개수에 따라 조절
                    itemBuilder: (context, index) {
                      // 각 메모를 나타내는 위젯 반환
                      return ListTile(
                        textColor: Colors.white,
                        title: Text('Memo $index',
                        style: TextStyle(fontSize: 60)),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}


