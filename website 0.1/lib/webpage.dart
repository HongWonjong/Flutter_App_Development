import 'package:flutter/material.dart';
import 'style/media_query_custom.dart';
import 'component/custom_app_bar.dart';
import 'component/body_part.dart';
import 'style/language.dart';
import 'component/header.dart';

class MyApp extends StatelessWidget {
  final List<String> imagePath1 = [
    'lib/images/그지.jpg',
    'lib/images/그지.jpg',
    'lib/images/그지.jpg',
    'lib/images/그지.jpg',
    // Add more image paths as needed
  ];
  final List<String> imagePath2 = [
    'lib/images/한잔해.jpg',
    'lib/images/한잔해.jpg',
    'lib/images/한잔해.jpg',
    'lib/images/한잔해.jpg',
    // Add more image paths as needed
  ];

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: const CustomAppBar(),
        body: Builder(
          builder: (context) {
            return Column(
              children: [
                HeaderPage(
                  imagePaths: imagePath1,
                  imageHeight: MQSize.getDetailHeight3(context),
                  imageWidth: MQSize.getDetailHeight3(context),// 외부에서 이미지 높이 설정
                  textYouWant: mainpage_lan.begging,
                ),
                HeaderPage(
                  imagePaths: imagePath2,
                  imageHeight: MQSize.getDetailHeight3(context),
                  imageWidth: MQSize.getDetailHeight2(context),
                  textYouWant: mainpage_lan.commercialPlease,
                ),
                Expanded(
                  child: Row(
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
                ),
                Expanded(
                  child: Row(
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}




