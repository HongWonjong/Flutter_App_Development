import 'package:flutter/material.dart';
import '../style/media_query_custom.dart';
import '../component/custom_app_bar.dart';
import '../component/question_and_answer_box.dart';
import '../style/language.dart';
import '../component/header.dart';
import '../style/image_path.dart';
import '../function/google_auth.dart';
import '../style/color.dart';
import '../component/message_response_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../component/chat_log_box.dart';
import '../function/get_response.dart';
import '../component/basic_box.dart';
import 'package:website/function/riverpod_setting.dart';


class MyApp extends ConsumerWidget {
  MyApp({Key? key}) : super(key: key);
  AuthFunctions authFunctions = AuthFunctions();


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authStateProvider);

    return MaterialApp(
      home: Scaffold(
        appBar:  const CustomAppBar(),
        body: isLoggedIn // 로그인 상태에 따라 조건부 렌더링
            ? Stack(
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

            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: MQSize.getDetailHeight1(context)),
                  SizedBox(height: MQSize.getDetailHeight1(context)),
                  HeaderPage(
                    height: MQSize.getDetailHeight4(context),
                    width: MQSize.getDetailWidth99(context),
                    imagePaths: ImagePaths.imagePath2,
                    imageHeight: MQSize.getDetailHeight5(context),
                    imageWidth: MQSize.getDetailWidth4(context),
                    textYouWant: MainPageLan.briefExplanation,
                  ),
                  SizedBox(height: MQSize.getDetailHeight1(context)),
                  Row(
                    children: [
                      Expanded(
                        child: QABox(
                          height: MQSize.getDetailHeight5(context),
                          width: MQSize.getDetailWidth5(context),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: ChatLogBox(
                            title: MainPageLan.geminiPro,
                            height: MQSize.getDetailHeightHalf(context),
                            width: MQSize.getDetailWidth5(context),
                            deleteDocArg: FunctionLan.geminiDoc,
                            child: MessageListWidget(modelResponseStream: listenForGeminiProResponse()),
                          )),
                      Expanded(
                        child: ChatLogBox(
                          title: MainPageLan.gpt35,
                          height: MQSize.getDetailHeightHalf(context),
                          width: MQSize.getDetailWidth5(context),
                          deleteDocArg: FunctionLan.gpt35Doc,
                          child: MessageListWidget(modelResponseStream: listenForGPT35Response()),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ChatLogBox(
                          title: MainPageLan.gpt4,
                          height: MQSize.getDetailHeightHalf(context),
                          width: MQSize.getDetailWidth5(context),
                          deleteDocArg: FunctionLan.gpt4Doc,
                          child: MessageListWidget(modelResponseStream: listenForGPT4Response()),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: BasicBox(
                          title: MainPageLan.autoGpt,
                          height: MQSize.getDetailHeight5(context),
                          width: MQSize.getDetailWidth5(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ) : const Center(child: Text('로그인이 필요합니다.')),
    ),
    );
  }
}





