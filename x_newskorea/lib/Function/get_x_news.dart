import 'dart:convert';
import 'package:http/http.dart' as http;

class XNewsService {
  static const String _baseUrl = 'api.twitter.com';
  static const String _apiKey = 'YOUR_API_KEY'; // 실제 API 키로 교체
  static const String _apiSecret = 'YOUR_API_SECRET'; // 실제 API 비밀 키로 교체
  static const String _accessToken = 'YOUR_ACCESS_TOKEN'; // 실제 액세스 토큰으로 교체
  static const String _accessTokenSecret = 'YOUR_ACCESS_TOKEN_SECRET'; // 실제 액세스 토큰 비밀 키로 교체

  static Future<List<XPost>> getCommunityPosts(String communityId) async {
    final String url = '$_baseUrl/2/timeline/community/$communityId';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $_accessToken',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('data')) {
          return (data['data'] as List<dynamic>)
              .map((json) => XPost.fromJson(json))
              .toList();
        } else {
          throw Exception('No data found in response');
        }
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      print('Error fetching X posts: $e');
      return [];
    }
  }
}

class XPost {
  final String id;
  final String text;
  final String authorId;

  XPost({required this.id, required this.text, required this.authorId});

  factory XPost.fromJson(Map<String, dynamic> json) {
    return XPost(
      id: json['id'],
      text: json['text'],
      authorId: json['author_id'],
    );
  }
}

// 사용 예시
Future<void> checkForNewPosts(String communityId) async {
  List<XPost> posts = await XNewsService.getCommunityPosts(communityId);
  if (posts.isNotEmpty) {
    print('New posts found:');
    for (var post in posts) {
      print('ID: ${post.id}, Text: ${post.text}, Author: ${post.authorId}');
    }
  } else {
    print('No new posts found.');
  }
}