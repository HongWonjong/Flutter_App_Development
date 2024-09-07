import 'package:flutter/material.dart';

class NewsDetailPage extends StatelessWidget {
  final Map<String, dynamic> newsItem;
  final String newsId;

  NewsDetailPage({required this.newsItem, required this.newsId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(newsItem['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.asset(newsItem['image'], fit: BoxFit.cover),
            SizedBox(height: 10),
            Text(newsItem['summary'], style: Theme.of(context).textTheme.bodyText1),
            // 여기에 더 많은 뉴스 디테일을 추가할 수 있습니다.
          ],
        ),
      ),
    );
  }
}