import 'package:flutter/material.dart';
import 'style/media_query_custom.dart';
import 'component/custom_app_bar.dart';
import 'component/question_and_answer_box.dart';
import 'style/language.dart';
import 'component/header.dart';
import 'style/image_path.dart';
import 'function/google_auth.dart';
import 'style/color.dart';


class MyApp extends StatelessWidget {
   MyApp({Key? key}) : super(key: key);
  AuthFunctions authFunctions = AuthFunctions();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar:  const CustomAppBar(),
        body: Stack(
          children: [
            /* Gradient background */
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

            /* SingleChildScrollView containing the layout */
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: MQSize.getDetailHeight1(context)),
                  HeaderPage(
                    imagePaths: ImagePaths.imagePath1,
                    imageHeight: MQSize.getDetailHeight3(context),
                    imageWidth: MQSize.getDetailWidth3(context),
                    textYouWant: mainpage_lan.begging,
                  ),
                  SizedBox(height: MQSize.getDetailHeight1(context)),
                  HeaderPage(
                    imagePaths: ImagePaths.imagePath2,
                    imageHeight: MQSize.getDetailHeight3(context),
                    imageWidth: MQSize.getDetailWidth3(context),
                    textYouWant: mainpage_lan.commercialPlease,
                  ),
                  SizedBox(height: MQSize.getDetailHeight1(context)),
                  /*HeaderPage(
                    imagePaths: ImagePaths.imagePath3,
                    imageHeight: MQSize.getDetailHeight4(context),
                    imageWidth: MQSize.getDetailWidth3(context),
                    textYouWant: mainpage_lan.popPop,
                  ),
                  SizedBox(height: MQSize.getDetailHeight1(context)),*/
                  Row(
                    children: [
                      /*ElevatedButton(
                        onPressed: () {
                          authFunctions.signInWithGoogle();
                        },
                        child: Text("로그인"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          authFunctions.signOut();
                        },
                        child: Text("로그아웃"),
                      ),*/

                      Expanded(
                        child: QABox(
                          text: mainpage_lan.bodyPart1,
                          height: MQSize.getDetailHeightHalf(context),
                          width: MQSize.getDetailWidth90(context),
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      /*Expanded(
                        child: BodyPage(
                          text: mainpage_lan.bodyPart3,
                          height: MQSize.getDetailHeight5(context),
                          width: MQSize.getDetailWidth5(context),
                        ),
                      ),
                      Expanded(
                        child: BodyPage(
                          text: mainpage_lan.bodyPart4,
                          height: MQSize.getDetailHeight5(context),
                          width: MQSize.getDetailWidth5(context),
                        ),
                      ),*/
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




