import 'package:flutter/material.dart';
import 'package:website/style/color.dart';
import 'package:website/style/language.dart';
import 'package:website/style/media_query_custom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:website/function/send_prompt.dart';
import 'message_response_list.dart';


class QABox extends StatefulWidget {
  final String text;
  final double height;
  final double width;
  final Color backgroundColor;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets margin;
  final EdgeInsets padding;

  const QABox({
    Key? key,
    required this.text,
    required this.height,
    required this.width,
    this.backgroundColor = AppColors.bodyPageBackground,
    this.borderRadius = 10.0,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  _QABoxState createState() => _QABoxState();
}

class _QABoxState extends State<QABox> {

  final TextEditingController _textController = TextEditingController();
  bool isTextEmpty = true;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        isTextEmpty = _textController.text.isEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: widget.borderColor, width: widget.borderWidth),
      ),
      margin: widget.margin,
      padding: widget.padding,
      height: widget.height,
      width: widget.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                flex: 95,
                child: TextFormField(
                  minLines: null,
                  maxLines: null,
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: mainpage_lan.hintText,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: MQSize.getDetailWidth01(context)),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      return isTextEmpty ? Colors.white24 : Colors.white;
                    },
                  ),
                ),
                child: const Text(mainpage_lan.sendMessage, style: TextStyle(color: AppColors.textColor)),
                onPressed: () {
                  if (!isTextEmpty) {
                    // Assuming you have the user's UID and discussion ID available
                    String uid = FirebaseAuth.instance.currentUser!.uid;
                    // Call the function to send the message to Firestore
                    sendMessageToFirestore(uid, _textController.text);

                    // Optionally, you can clear the text field after sending the message
                    _textController.clear();
                  }
                },
              ),

            ],
          ),
        ],
      ),
    );
  }
}



