import 'package:flutter/material.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/component/sized_box.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/l10n/language.dart';

class ShareDialog extends StatelessWidget {
  const ShareDialog({Key? key}) : super(key: key);

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
                            // 이메일 입력 필드
                            TextField(
                              cursorColor: AppColors.mainPageButtonTextColor,
                              maxLines: null,
                              minLines: null,
                              textAlignVertical: TextAlignVertical.top,
                              style: AdaptiveText.mediumTextStyle(context, color: AppColors.mainPageButtonTextColor),
                              decoration: const InputDecoration(
                                hintText: deleteDialog_lan.hintText,
                              ),
                            ),
                            const AdaptiveSizedBox(),
                            MediumButton(
                                buttonColor: AppColors.listViewBackgroundColor,
                                onPressed: () {

                                },
                                buttonText: deleteDialog_lan.deleteMemo,
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

