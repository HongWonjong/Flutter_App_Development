import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'style/media_query_custom.dart';  // MediaQueryUtil을 추가로 임포트
import 'component/custom_app_bar.dart';
import 'component/body_part.dart';  // BodyPage의 파일명을 맞게 수정
import 'style/language.dart';

void main() {
  html.window.onBeforeUnload.listen((event) {
    // 앱 종료 시 실행될 코드
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(),
        body: Builder(
          builder: (context) {
            return Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: BodyPage(
                          text: mainpage_lan.commercial,
                          height: MediaQueryUtil.getDetailHeight3(context),
                          width: MediaQueryUtil.getDetailWidth5(context),
                        ),
                      ),
                      Expanded(
                        child: BodyPage(
                          text: mainpage_lan.commercial,
                          height: MediaQueryUtil.getDetailHeight3(context),
                          width: MediaQueryUtil.getDetailWidth5(context),
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
                          text: mainpage_lan.bodyPart1,
                          height: MediaQueryUtil.getDetailHeight5(context),
                          width: MediaQueryUtil.getDetailWidth5(context),
                        ),
                      ),
                      Expanded(
                        child: BodyPage(
                          text: mainpage_lan.bodyPart2,
                          height: MediaQueryUtil.getDetailHeight5(context),
                          width: MediaQueryUtil.getDetailWidth5(context),
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
                          height: MediaQueryUtil.getDetailHeight5(context),
                          width: MediaQueryUtil.getDetailWidth5(context),
                        ),
                      ),
                      Expanded(
                        child: BodyPage(
                          text: mainpage_lan.bodyPart4,
                          height: MediaQueryUtil.getDetailHeight5(context),
                          width: MediaQueryUtil.getDetailWidth5(context),
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
