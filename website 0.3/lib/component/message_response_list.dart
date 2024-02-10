import 'package:flutter/material.dart';
import 'package:website/function/get_response.dart';
import 'package:website/style/media_query_custom.dart'; // 적절한 경로로 수정해주세요
import 'package:rxdart/rxdart.dart';

class MessageListWidget extends StatelessWidget {


  Stream<List<String>> getModelResponseStream() {
    // Combine responses from both models using rxdart
    Stream<List<String>> geminiStream = listenForGeminiProResponse();
    Stream<List<String>> gpt35Stream = listenForGPT35Response();

    return Rx.concat([geminiStream, gpt35Stream]);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: getModelResponseStream(),
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
                  width: MQSize.getDetailWidth90(context),
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  child: Text(
                    message,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
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



