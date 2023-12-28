import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              // Home 아이콘을 클릭했을 때 실행되는 코드
            },
            child: Icon(Icons.home),
          ),
          InkWell(
            onTap: () {
              // Search 아이콘을 클릭했을 때 실행되는 코드
            },
            child: Icon(Icons.search),
          ),
          InkWell(
            onTap: () {
              // Favorite 아이콘을 클릭했을 때 실행되는 코드
            },
            child: Icon(Icons.favorite),
          ),
          InkWell(
            onTap: () {
              // Notifications 아이콘을 클릭했을 때 실행되는 코드
            },
            child: Icon(Icons.notifications),
          ),
          InkWell(
            onTap: () {
              // Settings 아이콘을 클릭했을 때 실행되는 코드
            },
            child: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}

