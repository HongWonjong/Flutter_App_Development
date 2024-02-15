import 'package:flutter/material.dart';
import '../style/media_query_custom.dart';
import '../component/custom_app_bar.dart';
import '../component/question_box.dart';
import '../style/language.dart';
import '../component/header.dart';
import '../style/image_path.dart';
import '../function/google_auth.dart';
import '../style/color.dart';
import '../component/message_response_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../component/chat_log_box.dart';
import '../function/get_chat_response.dart';
import '../component/basic_box.dart';
import 'package:website/function/riverpod_setting.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:website/function/get_chat_title.dart';


class MyApp extends ConsumerWidget {
  MyApp({Key? key}) : super(key: key);
  AuthFunctions authFunctions = AuthFunctions();


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.maybeWhen(
      data: (user) => user != null, // User 객체가 null이 아니면 로그인한 것으로 간주
      orElse: () => false, // 그 외의 경우에는 로그인하지 않은 것으로 간주
    );
    // 구글 어널리틱스 관련 코드
     FirebaseAnalytics analytics = FirebaseAnalytics.instance;
     FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
    FirebaseAnalyticsObserver(analytics: analytics);
     //

    return MaterialApp(
      navigatorObservers: <NavigatorObserver>[observer],

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
                    imageWidth: MQSize.getDetailWidth5(context),
                    textYouWant: MainPageLan.briefExplanation,
                  ),
                  SizedBox(height: MQSize.getDetailHeight1(context)),
                  Row(
                    children: [
                      Expanded(
                        child: QBox(
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
                            child: MessageListWidget(
                                modelResponseStream:listenForResponses(FunctionLan.geminiDoc, 'prompt', 'response','createTime'),
                                titleResponseStream: listenForTitle(FunctionLan.geminiDoc, 'createTime')
                            ),
                          )),
                      Expanded(
                        child: ChatLogBox(
                          title: MainPageLan.gpt35,
                          height: MQSize.getDetailHeightHalf(context),
                          width: MQSize.getDetailWidth5(context),
                          deleteDocArg: FunctionLan.gpt35Doc,
                          child: MessageListWidget(
                              modelResponseStream: listenForResponses(FunctionLan.gpt35Doc, 'gpt35_prompt', 'gpt35_response', 'status.created_at'),
                              titleResponseStream: listenForTitle(FunctionLan.gpt35Doc, 'status.created_at')
                          ),
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
                          child: MessageListWidget(
                              modelResponseStream: listenForResponses(FunctionLan.gpt4Doc, 'gpt4_prompt', 'gpt4_response', 'status.created_at'),
                              titleResponseStream: listenForTitle(FunctionLan.gpt4Doc, 'status.created_at')
                          ),
                        ),
                      ),
                      Expanded(
                        child: ChatLogBox(
                          title: MainPageLan.palm,
                          height: MQSize.getDetailHeightHalf(context),
                          width: MQSize.getDetailWidth5(context),
                          deleteDocArg: FunctionLan.palmDoc,
                          child: MessageListWidget(
                              modelResponseStream: listenForResponses(FunctionLan.palmDoc, 'palm_prompt', 'palm_response', 'createTime'),
                              titleResponseStream: listenForTitle(FunctionLan.palmDoc, 'createTime')
                          ),
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
        ) :  Stack(
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
              child: Column(
                children: [
                  SizedBox(height: MQSize.getDetailHeight1(context)),
                  HeaderPage(
                    height: MQSize.getDetailHeight4(context),
                    width: MQSize.getDetailWidth99(context),
                    imagePaths: ImagePaths.imagePath2,
                    imageHeight: MQSize.getDetailHeight5(context),
                    imageWidth: MQSize.getDetailWidth5(context),
                    textYouWant: MainPageLan.briefExplanation,
                  ),
                   Text("로그인 후 이용해주세요", style: TextStyle(fontSize: MQSize.getDetailWidth1(context), color: AppColors.whiteTextColor),),
                ],
              ),
    ),
          ],
        ),
    ),
    );
  }
}





