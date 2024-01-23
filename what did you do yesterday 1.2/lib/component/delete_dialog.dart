import 'package:flutter/material.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/component/sized_box.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/l10n/language.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      child: Container(
        height: screenHeight * 0.6,
        width: screenWidth * 0.8,
        child: Scaffold(
          backgroundColor: AppColors.dialogBackgroundColor,
          body: Padding(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: screenHeight * 0.555,
                  color: AppColors.listViewBackgroundColor,
                  child: Column(
                    children: [
                      // Center에 email 입력 필드 및 공유 버튼 추가
                      Center(
                        child: Column(
                          children: [
                            const AdaptiveSizedBox(),
                            MediumButton(
                                buttonColor: AppColors.warningColor,
                                onPressed: () {

                                },
                                buttonText: shareDialog_lan.deleteMemo,
                                textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.mainPageButtonTextColor)),
                          ],
                        ),
                      ),
                    ],
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

