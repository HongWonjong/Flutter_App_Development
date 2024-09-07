import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'news_home_page/news_home_page.dart';
import 'news_detail_page.dart';
import 'data/dummy_news_data.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => NewsHomePage(),
        ),
        GoRoute(
          path: '/news/:newsId',
          builder: (context, state) {
            final String newsId = state.pathParameters['newsId']!;
            // newsId로 newsItem 찾기
            final Map<String, dynamic>? newsItem = news.firstWhere(
                  (item) => item['id'] == newsId,
              orElse: () => null!,
            );

            if (newsItem == null) {
              return Scaffold(
                body: Center(child: Text('News not found')),
              );
            }

            return NewsDetailPage(newsItem: newsItem, newsId: newsId);
          },
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: _router,
      title: 'X-News Korea',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}


