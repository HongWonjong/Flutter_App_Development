import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:x_newskorea/news_detail_page.dart';
import 'dummy_data.dart';

class HeadlineSection extends StatelessWidget {
  final List<Map<String, dynamic>> headlines;

  HeadlineSection({required this.headlines});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: headlines.asMap().map((index, item) => MapEntry(index, Builder(
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailPage(newsId: item['id'], newsItem: item),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                children: <Widget>[
                  Image.asset(item['image'], fit: BoxFit.cover, height: 200),
                  Text(item['title'], style: TextStyle(fontSize: 16.0)),
                ],
              ),
            ),
          );
        },
      ))).values.toList(),
      options: CarouselOptions(
        height: 250.0,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16/9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
    );
  }
}