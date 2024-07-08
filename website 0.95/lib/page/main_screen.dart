import 'package:flutter/material.dart';
import '../style/color.dart';
import '../style/image_path.dart';
import '../style/language.dart';
import '../style/media_query_custom.dart';
import '../component/chat_log_box.dart';
import 'package:website/component/header.dart';
import '../component/question_box.dart';
import '../component/message_response_list.dart';
import '../function/get_chat_response.dart';
import '../component/basic_box.dart';
import 'package:website/component/component_extended/question_box_extended.dart';
import 'package:website/component/AIVtuberWidget.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                imagePaths: ImagePaths.toothless,
                imageHeight: MQSize.getDetailHeight4(context),
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
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ChatLogBox(
                      title: MainPageLan.fibi,
                      height: MQSize.getDetailHeightHalf(context),
                      width: MQSize.getDetailWidth5(context),
                      deleteDocArg: FunctionLan.fibiDoc,
                      child: MessageListWidget(
                          modelResponseStream: listenForResponses(FunctionLan.fibiDoc, 'fb_prompt', 'fb_response', 'createTime'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ChatLogBox(
                      title: ExtendedMainPageLan.modelNameGpt35,
                      height: MQSize.getDetailHeightHalf(context),
                      width: MQSize.getDetailWidth5(context),
                      deleteDocArg: ExtendedfunctionLan.gpt35Doc,
                      child: MessageListWidget(
                          modelResponseStream: listenForResponses(ExtendedfunctionLan.gpt35Doc, 'stream_gpt35_prompt', 'stream_gpt35_response', 'createTime'),
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
              Row(
                children: [
                  Expanded(
                    child: QBoxExtended(
                      height: MQSize.getDetailHeight5(context),
                      width: MQSize.getDetailWidth5(context),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: BasicBox(
                      title: MainPageLan.aiVtuber,
                      height: MQSize.getDetailHeight90(context),
                      width: MQSize.getDetailWidth5(context),
                      child: AIVtuberWidget(),
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
