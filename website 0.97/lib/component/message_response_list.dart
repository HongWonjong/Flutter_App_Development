import 'package:flutter/material.dart';
import 'package:website/style/media_query_custom.dart';
import 'package:website/style/language.dart';
import 'selectable_formatted_text.dart';


class MessageListWidget extends StatelessWidget {
  final Stream<List<String>> modelResponseStream;


  const MessageListWidget({
    Key? key,
    required this.modelResponseStream,


  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<List<String>>(
          stream: modelResponseStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('다시 로그인 하세요.');
            } else {
              List<String> messagesAndResponses = snapshot.data ?? [];

              if (messagesAndResponses.isEmpty) {
                return Text(MainPageLan.noChatLog, style: TextStyle(fontSize: MQSize.getDetailWidth1(context)));
              }
              return Column(
                children: messagesAndResponses.map((message) {
                  return Align(
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      width: MQSize.getDetailWidthHalf(context),
                      margin: EdgeInsets.symmetric(vertical: MQSize.getDetailHeight1(context)),
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('당신의 대화 내용'),
                                content: SingleChildScrollView(
                                  child: SelectableFormattedTextWidget( // Text 대신 사용하면 해당 글은 복사가 가능하다.
                                    text: message,// Allows unlimited lines
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('닫기'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          alignment: Alignment.centerLeft, // 텍스트를 왼쪽으로 정렬
                        ),
                        child: Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }
          },
        ),
      ],
    );
  }
}







