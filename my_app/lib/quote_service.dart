import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  Future<String> getDailyQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://zenquotes.io/api/random'),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final quote = data[0]['q']; // Текст цитаты
          final author = data[0]['a']; // Автор
          return '"$quote" - $author';
        }
      }
      return 'Сегодняшний день - это возможность стать лучше.';
    } catch (e) {
      return 'Маленькие шаги каждый день приводят к большим результатам.';
    }
  }
}