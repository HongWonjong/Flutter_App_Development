import 'package:flutter/material.dart';
import 'headline_sections.dart';
import 'category_section.dart';
import 'news_list_section.dart';
import 'recommended_news_section.dart';
import 'package:x_newskorea/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logo_link.dart';

class NewsHomePage extends StatefulWidget {
  @override
  _NewsHomePageState createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
// 더미 데이터
  final List<Map<String, dynamic>> headlines = [
    {'id': '12345678901234567890', 'title': 'Headline 1', 'image': 'assets/headline1.jpg'},
    {'id': '23456789012345678901', 'title': 'Headline 2', 'image': 'assets/headline2.jpg'},
    {'id': '34567890123456789012', 'title': 'Headline 3', 'image': 'assets/headline3.jpg'},
  ];

  final List<String> categories = ['Politics', 'Tech', 'Sports', 'Entertainment'];

  final List<Map<String, dynamic>> news = [
    {'id': '45678901234567890123', 'title': 'News 1', 'summary': 'Summary of news 1', 'image': 'assets/news1.jpg'},
    {'id': '56789012345678901234', 'title': 'News 2', 'summary': 'Summary of news 2', 'image': 'assets/news2.jpg'},
    {'id': '67890123456789012345', 'title': 'News 3', 'summary': 'Summary of news 3', 'image': 'assets/news3.jpg'},
  ];

  final List<Map<String, dynamic>> recommendedNews = [
    {'id': '78901234567890123456', 'title': 'Recommended 1', 'image': 'assets/recommended1.jpg'},
    {'id': '89012345678901234567', 'title': 'Recommended 2', 'image': 'assets/recommended2.jpg'},
    {'id': '90123456789012345678', 'title': 'Recommended 3', 'image': 'assets/recommended3.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('환영합니다, ${user.email}님!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: launchXProfile,
          child: Image.asset(
            'assets/logo.png',
            width: 40,
          ),
        ),
        title: Text('X News Korea'),
        actions: <Widget>[
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
              if (snapshot.hasData) {
                return IconButton(
                  color: Colors.grey,
                  icon: const Icon(Icons.logout),
                  iconSize: 40,
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                );
              } else {
                return IconButton(
                  color: Colors.grey,
                  icon: const Icon(Icons.person),
                  iconSize: 40,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            HeadlineSection(headlines: headlines),
            CategorySection(categories: categories),
            NewsListSection(news: news),
            Container(height: 100, color: Colors.grey[200], child: Center(child: Text('Ad Space'))),
            RecommendedNewsSection(recommendedNews: recommendedNews),
          ],
        ),
      ),
    );
  }
}