import 'package:flutter/material.dart';
import 'package:freedomcompass/component/app_bar.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/component/sized_box.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/function/navigator.dart';
import 'main_page.dart';
import 'package:freedomcompass/component/memo_text_field.dart';

class CreateMemoPage extends StatefulWidget {
  @override
  _CreateMemoPageState createState() => _CreateMemoPageState();
}

class _CreateMemoPageState extends State<CreateMemoPage> {
  TextEditingController _memoController = TextEditingController(); // 텍스트 필드의 컨트롤러

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const CustomAppBar(titleText: mainpage_lan.mainPageTitle),
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
                    // 입력된 메모 내용 사용 가능
                    String memoText = _memoController.text;
                    print('입력된 메모: $memoText');

                    NavigatorHelper.goToPage(context, const MainPage());
                  },
                  buttonText: createpage_lan.createfinished,
                  textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.mainPageButtonTextColor),
                ),
                const AdaptiveSizedBox(),
                // 텍스트 필드 추가
                MemoTextFieldWidget(memoController: _memoController),
              ],
            ),
          ),
        ),
    );
  }
}


