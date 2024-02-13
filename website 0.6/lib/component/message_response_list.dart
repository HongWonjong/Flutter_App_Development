import 'package:flutter/material.dart';
import 'package:website/style/media_query_custom.dart';
import 'package:website/style/language.dart';

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
              return const CircularProgressIndicator();
            } else {
              List<String> messagesAndResponses = snapshot.data ?? [];

              if (messagesAndResponses.isEmpty) {
                return Text(MainPageLan.noChatLog, style: TextStyle(fontSize: MQSize.getDetailHeight11(context)));
              }

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
        ),
      ],
    );
  }
}






