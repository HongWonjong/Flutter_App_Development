import 'package:flutter/material.dart';
import 'package:x_newskorea/news_detail_page.dart';

class RecommendedNewsSection extends StatelessWidget {
  final List<Map<String, dynamic>> recommendedNews;

  RecommendedNewsSection({required this.recommendedNews});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Recommended for you', style: Theme.of(context).textTheme.headline6),
        ),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendedNews.length,
            itemBuilder: (context, index) {
              return GestureDetector( // Wrap with GestureDetector for tap functionality
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailPage(newsId: recommendedNews[index]['id'],newsItem: recommendedNews[index]),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    children: <Widget>[
                      Image.asset(recommendedNews[index]['image'], width: 150, height: 150),
                      Text(recommendedNews[index]['title']),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}