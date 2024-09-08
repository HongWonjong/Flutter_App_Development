import 'package:flutter/material.dart';
import 'headline_sections.dart';
import 'category_section.dart';
import 'news_list_section.dart';
import 'recommended_news_section.dart';
import 'package:x_newskorea/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logo_link.dart';
import 'dummy_data.dart';

class NewsHomePage extends StatefulWidget {
  @override
  _NewsHomePageState createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
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
            HeadlineSection(headlines: DummyData.headlines),
            CategorySection(categories: DummyData.categories),
            NewsListSection(news: DummyData.news),
            Container(height: 100, color: Colors.grey[200], child: Center(child: Text('Ad Space'))),
            RecommendedNewsSection(recommendedNews: DummyData.recommendedNews),
          ],
        ),
      ),
    );
  }
}