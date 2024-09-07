import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  final String category;

  const CategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${category} News'),
      ),
      body: ListView.builder(
        itemCount: 10, // Assuming you have 10 news items for demonstration
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Image.asset('assets/news${index + 1}.jpg', width: 100, fit: BoxFit.cover), // Placeholder image
              title: Text('News Title $index in $category'),
              subtitle: Text('This is a summary or description of the news item.'),
              onTap: () {
                // Here you would typically navigate to a detailed news page
                print('Navigate to news detail page for item $index in $category');
              },
            ),
          );
        },
      ),
    );
  }
}

// To navigate to this page from your CategorySection, you might do something like this:

class CategorySection extends StatelessWidget {
  final List<String> categories;

  const CategorySection({Key? key, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryPage(category: categories[index])),
                );
              },
              child: Text(categories[index]),
            ),
          );
        },
      ),
    );
  }
}