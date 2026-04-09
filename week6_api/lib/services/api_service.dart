import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ApiService {
  final String _baseUrl = 'newsapi.org';
  final String _apiKey = '9941cd65876e44f9a47d87c31b9a67c9';

  Future<List<Article>> fetchNewsArticles() async {
    final uri = Uri.https(
      _baseUrl,
      '/v2/top-headlines',
      {
        'country': 'us',
        'apiKey': _apiKey,
      },
    );

    try {
      final response = await http.get(uri);

      // HTTP error handling
      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final Map<String, dynamic> jsonData =
          jsonDecode(response.body);

      final List<dynamic> articlesJson =
          jsonData['articles'];

      return articlesJson
          .map((json) => Article.fromJson(json))
          .toList();

    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}