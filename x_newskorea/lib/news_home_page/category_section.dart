import 'package:flutter/material.dart';
import 'package:x_newskorea/news_category_page/news_category_page.dart';

class CategorySection extends StatelessWidget {
  final List<String> categories;

  CategorySection({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Categories', style: Theme.of(context).textTheme.headline6),
        ),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector( // Add GestureDetector for tap
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryPage(category: categories[index]),
                      ),
                    );
                  },
                  child: Chip(
                    label: Text(categories[index]),
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