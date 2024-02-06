import 'package:flutter/material.dart';
import 'style/media_query_custom.dart';
import 'component/custom_app_bar.dart';
import 'component/body_part.dart';
import 'style/language.dart';
import 'component/header.dart';
import 'style/image_path.dart';

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(),
        body: SingleChildScrollView( // 변경된 부분
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
                imageHeight: MQSize.getDetailHeight4(context),
                imageWidth: MQSize.getDetailWidth3(context),
                textYouWant: mainpage_lan.commercialPlease,
              ),
              SizedBox(height: MQSize.getDetailHeight1(context)),
              HeaderPage(
                imagePaths: ImagePaths.imagePath3,
                imageHeight: MQSize.getDetailHeight4(context),
                imageWidth: MQSize.getDetailWidth3(context),
                textYouWant: mainpage_lan.popPop,
              ),
              SizedBox(height: MQSize.getDetailHeight1(context)),
              Row(
                children: [
                  Expanded(
                    child: BodyPage(
                      text: mainpage_lan.bodyPart1,
                      height: MQSize.getDetailHeight5(context),
                      width: MQSize.getDetailWidth5(context),
                    ),
                  ),
                  Expanded(
                    child: BodyPage(
                      text: mainpage_lan.bodyPart2,
                      height: MQSize.getDetailHeight5(context),
                      width: MQSize.getDetailWidth5(context),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}




