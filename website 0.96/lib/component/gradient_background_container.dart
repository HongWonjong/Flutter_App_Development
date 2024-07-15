import 'package:flutter/material.dart';
import '../style/color.dart';

class GradientBackgroundContainer extends StatelessWidget {
  const GradientBackgroundContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.bodyGradationLeft,
            AppColors.bodyGradationRight,
          ],
        ),
      ),
    );
  }
}
