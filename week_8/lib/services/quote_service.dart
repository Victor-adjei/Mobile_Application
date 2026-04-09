import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote.dart';

class QuoteService {
  static const List<String> _apiUrls = [
    'https://api.quotable.io/random',
    'https://zenquotes.io/api/random',
  ];

  static const List<Quote> _fallbackQuotes = [
    Quote(
      text: 'Small consistent steps create big outcomes over time.',
      author: 'Campus Connect',
    ),
    Quote(
      text: 'Progress matters more than perfection.',
      author: 'Campus Connect',
    ),
    Quote(
      text: 'Your future is built by what you do today.',
      author: 'Campus Connect',
    ),
  ];

  Future<Quote> fetchRandomQuote() async {
    for (final apiUrl in _apiUrls) {
      try {
        final response = await http
            .get(Uri.parse(apiUrl))
            .timeout(const Duration(seconds: 6));
        if (response.statusCode != 200) {
          continue;
        }

        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return Quote.fromJson(data);
        }

        if (data is List &&
            data.isNotEmpty &&
            data.first is Map<String, dynamic>) {
          return Quote.fromJson(data.first as Map<String, dynamic>);
        }
      } catch (_) {
        // Try next source.
      }
    }

    final index =
        DateTime.now().millisecondsSinceEpoch % _fallbackQuotes.length;
    return _fallbackQuotes[index];
  }
}
