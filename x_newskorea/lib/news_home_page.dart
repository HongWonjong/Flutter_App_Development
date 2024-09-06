import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
    {'title': 'Headline 1', 'image': 'assets/headline1.jpg'},
    {'title': 'Headline 2', 'image': 'assets/headline2.jpg'},
    {'title': 'Headline 3', 'image': 'assets/headline3.jpg'},
  ];

  final List<String> categories = ['Politics', 'Tech', 'Sports', 'Entertainment'];

  final List<Map<String, dynamic>> news = [
    {'title': 'News 1', 'summary': 'Summary of news 1', 'image': 'assets/news1.jpg'},
    {'title': 'News 2', 'summary': 'Summary of news 2', 'image': 'assets/news2.jpg'},
    {'title': 'News 3', 'summary': 'Summary of news 3', 'image': 'assets/news3.jpg'},
  ];

  final List<Map<String, dynamic>> recommendedNews = [
    {'title': 'Recommended 1', 'image': 'assets/recommended1.jpg'},
    {'title': 'Recommended 2', 'image': 'assets/recommended2.jpg'},
    {'title': 'Recommended 3', 'image': 'assets/recommended3.jpg'},
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
        // 로그인 상태일 때 환영 메시지를 표시
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
          onTap: launchXProfile, // utils.dart에 정의된 함수를 호출
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
                    // 로그아웃 기능 추가
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
            // 헤드라인 뉴스 섹션
            CarouselSlider(
              items: headlines.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Column(
                        children: <Widget>[
                          Image.asset(i['image'], fit: BoxFit.cover, height: 200),
                          Text(i['title'], style: TextStyle(fontSize: 16.0)),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
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
            ),

            // 카테고리 섹션
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
                    child: Chip(
                      label: Text(categories[index]),
                      onDeleted: () {},
                    ),
                  );
                },
              ),
            ),

            // 최신 뉴스 리스트
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
                            onPressed: () { /* ... */ },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // 광고 및 추천 섹션
            Container(
              height: 100,
              color: Colors.grey[200],
              child: Center(child: Text('Ad Space')),
            ),
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
                  return Card(
                    child: Column(
                      children: <Widget>[
                        Image.asset(recommendedNews[index]['image'], width: 150, height: 150),
                        Text(recommendedNews[index]['title']),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}