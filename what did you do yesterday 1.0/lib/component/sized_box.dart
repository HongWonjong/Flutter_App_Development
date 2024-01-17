import 'package:flutter/material.dart';

class AdaptiveSizedBox extends StatelessWidget {
  final double heightFactor;

  const AdaptiveSizedBox({super.key, this.heightFactor = 0.02});

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double adaptedHeight = deviceHeight * heightFactor;

    return SizedBox(height: adaptedHeight);
  }
}
