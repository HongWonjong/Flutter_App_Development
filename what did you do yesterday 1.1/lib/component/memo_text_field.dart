import 'package:flutter/material.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/l10n/language.dart';

class MemoTextFieldWidget extends StatelessWidget {
  final TextEditingController memoController;

  const MemoTextFieldWidget({required this.memoController, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: Container(
        color: AppColors.listViewBackgroundColor,
        child: TextFormField(
          cursorColor: AppColors.mainPageButtonTextColor, // 클릭했을 때 생기는 커서 색
          maxLines: null,
          minLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          controller: memoController,
          style: AdaptiveText.mediumTextStyle(context, color: AppColors.mainPageButtonTextColor),
          decoration: InputDecoration(
            hintStyle: const TextStyle(color: AppColors.memoHintTextColor),
            hintText: createpage_lan.inputMemo,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.mainPageButtonTextColor), // 텍스트필드의 테두리 색
            ),
            contentPadding: EdgeInsets.all(screenHeight * 0.02),
          ),
        ),
      ),
    );
  }
}
