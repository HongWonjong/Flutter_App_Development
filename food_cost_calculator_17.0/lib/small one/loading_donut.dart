import 'package:flutter/material.dart';

class LoadingDonut extends StatelessWidget {
  const LoadingDonut({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,  // 추가: 위젯을 중앙에 위치시킴
      children: const [
        Opacity(
          opacity: 0.3,
          child: ModalBarrier(dismissible: false, color: Colors.black),
        ),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.blue),
        ),
        Positioned(
          bottom: 20,
          child: Text(
            'Loading...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

