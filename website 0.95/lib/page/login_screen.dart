import 'package:flutter/material.dart';
import '../style/color.dart';
import '../style/image_path.dart';
import '../style/language.dart';
import '../component/header.dart';
import '../style/media_query_custom.dart';
import 'package:website/component/basic_box.dart';
import 'package:website/component/AIVtuberWidget_unlogged.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration:   BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.bodyGradationLeft,
                AppColors.bodyGradationRight,
              ],
            ),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: MQSize.getDetailHeight1(context)),
              HeaderPage(
                height: MQSize.getDetailHeight4(context),
                width: MQSize.getDetailWidth99(context),
                imagePaths: ImagePaths.toothless,
                imageHeight: MQSize.getDetailHeight5(context),
                textYouWant: MainPageLan.briefExplanation,
              ),
              Text(MainPageLan.pleaseLogin, style: TextStyle(fontSize: MQSize.getDetailWidth1(context), color: AppColors.whiteTextColor),),
              Row(
                children: [
                  Expanded(
                    child: BasicBox(
                      title: MainPageLan.aiVtuber,
                      height: MQSize.getDetailHeight90(context),
                      width: MQSize.getDetailWidth5(context),
                      child: AIVtuberWidget_Unlogged(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

      ],
    );
  }
}
