import 'package:flutter/material.dart';
import 'package:website/style/media_query_custom.dart'; // 적절한 경로로 수정해주세요


class MessageListWidget extends StatelessWidget {
  final Stream<List<String>> modelResponseStream;

  const MessageListWidget({Key? key, required this.modelResponseStream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: modelResponseStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const CircularProgressIndicator();
        } else {
          List<String> messagesAndResponses = snapshot.data ?? [];

          return Column(
            children: messagesAndResponses.map((message) {
              return Align(
                alignment: Alignment.center,
                child: Container(
                  color: Colors.white,
                  width: MQSize.getDetailWidth90(context),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ExpansionTile(
                    title: Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          message,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }
}





