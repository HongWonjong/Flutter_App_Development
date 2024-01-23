import 'package:flutter/material.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/component/sized_box.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/function/delete_memo.dart';

class DeleteDialog extends StatelessWidget {
  final String memoId;

  const DeleteDialog({super.key, required this.memoId});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      child: SizedBox(
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

                      Center(
                        child: Column(
                          children: [
                            const AdaptiveSizedBox(),
                            const AdaptiveSizedBox(),
                            const AdaptiveSizedBox(),
                            const AdaptiveSizedBox(),
                            const AdaptiveSizedBox(),
                            const AdaptiveSizedBox(),
                            const AdaptiveSizedBox(),
                            const AdaptiveSizedBox(),
                            const AdaptiveSizedBox(),
                            const AdaptiveSizedBox(),

                            MediumButton(
                                buttonColor: AppColors.warningColor,
                                onPressed: () {
                                  deleteMemo(memoId);
                                  Navigator.pop(context);
                                },
                                buttonText: deleteDialog_lan.deleteMemo,
                                textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.mainPageButtonTextColor)),
                            Text(deleteDialog_lan.deleteText, style: AdaptiveText.mediumTextStyle(context, color: AppColors.warningColor)),

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

