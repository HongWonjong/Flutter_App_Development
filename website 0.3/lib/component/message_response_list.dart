import 'package:flutter/material.dart';
import 'package:website/function/get_response.dart';
import 'package:website/style/media_query_custom.dart'; // 적절한 경로로 수정해주세요

class MessageListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: listenForMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<String> messagesAndResponses = snapshot.data ?? [];

          return Column(
            children: messagesAndResponses.map((message) {
              return InkWell(
                onTap: () {
                  // 버튼이 눌리면 할 일 추가
                },
                child: Container(
                  width: MQSize.getDetailWidth90(context),
                  padding: EdgeInsets.all(16.0), // 내용과 상하좌우 간격 조절
                  margin: EdgeInsets.symmetric(vertical: 8.0), // 위아래 간격 조절
                  decoration: BoxDecoration(
                    color: Colors.white, // 배경 색상을 white 24로
                    borderRadius: BorderRadius.circular(0.0), // 모서리를 각진 모양으로
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


