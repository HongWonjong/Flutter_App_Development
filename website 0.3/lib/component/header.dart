// header_page.dart
import 'package:flutter/material.dart';
import 'package:website/style/media_query_custom.dart';

class HeaderPage extends StatelessWidget {
  final List<String> imagePaths;
  final String textYouWant;
  final double imageHeight;
  final double imageWidth;


  const HeaderPage({
    Key? key,
    required this.imagePaths,
    required this.textYouWant,
    required this.imageHeight,
    required this.imageWidth,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white24,
      child: Row(
        children: [
          for (String imagePath in imagePaths)
            SizedBox(
              child: Image.asset(
                imagePath,
                height: imageHeight,
                width: imageWidth,
              ),
            ),
          Expanded(
            child: Text(
              textYouWant,
              style: TextStyle(
                fontSize: MQSize.getDetailHeight11(context),
                // Adjust the fontSize according to your preference
              ),
            ),
          ),
        ],
      ),
    );
  }
}
