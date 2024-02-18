import 'package:flutter/material.dart';
import '../style/color.dart';
import '../style/image_path.dart';
import '../style/language.dart';
import '../component/header.dart';
import '../style/media_query_custom.dart';
import 'package:website/component/gradient_background_container.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const GradientBackgroundContainer(),
        Column(
          children: [
            SizedBox(height: MQSize.getDetailHeight1(context)),
            HeaderPage(
              height: MQSize.getDetailHeight4(context),
              width: MQSize.getDetailWidth99(context),
              imagePaths: ImagePaths.toothless,
              imageHeight: MQSize.getDetailHeight5(context),
              textYouWant: MainPageLan.briefExplanation,
            ),
            Text("로그인 후 이용해주세요", style: TextStyle(fontSize: MQSize.getDetailWidth1(context), color: AppColors.whiteTextColor),),
          ],
        ),
      ],
    );
  }
}
