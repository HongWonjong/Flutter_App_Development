import 'package:flutter/material.dart';
import 'package:x_newskorea/news_detail_page.dart';
import 'dummy_data.dart';

class NewsListSection extends StatelessWidget {
  final List<Map<String, dynamic>> news;

  NewsListSection({required this.news});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Latest News', style: Theme.of(context).textTheme.headline6),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: news.length,
          itemBuilder: (context, index) {
            return Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailPage(newsId: news[index]['id'], newsItem: news[index]),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Image.asset(news[index]['image'], width: 50, height: 50),
                      title: Text(news[index]['title']),
                      subtitle: Text(news[index]['summary']),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        TextButton(
                          child: const Text('READ MORE'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsDetailPage(newsId: news[index]['id'], newsItem: news[index]),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}