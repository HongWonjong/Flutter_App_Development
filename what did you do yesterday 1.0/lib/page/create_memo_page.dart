import 'package:flutter/material.dart';
import 'package:freedomcompass/component/app_bar.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/component/sized_box.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/function/navigator.dart';
import 'main_page.dart';

class CreateMemoPage extends StatefulWidget {
  @override
  _CreateMemoPageState createState() => _CreateMemoPageState();
}

class _CreateMemoPageState extends State<CreateMemoPage> {
  TextEditingController _memoController = TextEditingController(); // 텍스트 필드의 컨트롤러

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titleText: mainpage_lan.mainPageTitle),
      body: Container(
        color: AppColors.centerColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                Expanded(
                  child: TextField(
                    controller: _memoController,
                    maxLines: null, // 여러 줄의 텍스트를 입력할 수 있도록 함
                    style: AdaptiveText.mediumTextStyle(context, color: AppColors.mainPageButtonTextColor),
                    decoration: const InputDecoration(
                      hintText: '메모를 입력하세요',
                      border: OutlineInputBorder(), // 외곽선 추가
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


