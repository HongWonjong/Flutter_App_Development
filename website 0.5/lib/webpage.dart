import 'package:flutter/material.dart';
import 'style/media_query_custom.dart';
import 'component/custom_app_bar.dart';
import 'component/question_and_answer_box.dart';
import 'style/language.dart';
import 'component/header.dart';
import 'style/image_path.dart';
import 'function/google_auth.dart';
import 'style/color.dart';
import 'component/message_response_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'component/chat_log_box.dart';
import 'function/get_response.dart';
import 'component/basic_box.dart';


class MyApp extends ConsumerWidget {
   MyApp({Key? key}) : super(key: key);
  AuthFunctions authFunctions = AuthFunctions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final selectedModel = ref.watch(selectedModelProvider);
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
                  /*HeaderPage(
                    imagePaths: ImagePaths.imagePath1,
                    imageHeight: MQSize.getDetailHeight3(context),
                    imageWidth: MQSize.getDetailWidth3(context),
                    textYouWant: MainPageLan.begging,
                  ),*/
                  SizedBox(height: MQSize.getDetailHeight1(context)),
                  HeaderPage(
                    imagePaths: ImagePaths.imagePath2,
                    imageHeight: MQSize.getDetailHeight4(context),
                    imageWidth: MQSize.getDetailWidth4(context),
                    textYouWant: MainPageLan.briefExplanation,
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
                          height: MQSize.getDetailHeightHalf(context),
                          width: MQSize.getDetailWidth90(context),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      EmptyBox(
                        title: MainPageLan.geminiPro,
                        height: MQSize.getDetailHeight70(context),
                        width: MQSize.getDetailWidthHalf(context),
                        deleteDocArg: FunctionLan.geminiDoc,
                        child: MessageListWidget(modelResponseStream: listenForGeminiProResponse()),
                      ),
                      Expanded(
                        child: EmptyBox(
                          title: MainPageLan.gpt35,
                          height: MQSize.getDetailHeight70(context),
                          width: MQSize.getDetailWidthHalf(context),
                          deleteDocArg: FunctionLan.gpt35Doc,
                          child: MessageListWidget(modelResponseStream: listenForGPT35Response()),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: BasicBox(
                          title: MainPageLan.autoGpt,
                          height: MQSize.getDetailHeightHalf(context),
                          width: MQSize.getDetailWidth99(context),
                        ),
                      ),
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




