import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PixabayService {
  static final String _apiKey = dotenv.env['PIXABAY_API_KEY'] ?? '';
  static const String _baseUrl = 'https://pixabay.com/api/';

  Future<String?> getImageForPlace(String query) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?key=$_apiKey&q=${Uri.encodeQueryComponent(query)}'
            '&image_type=photo&per_page=3&orientation=horizontal',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['hits'] != null && data['hits'].isNotEmpty) {
          return data['hits'][0]['webformatURL'];
        }
      } else {
        print('❌ Pixabay API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Pixabay error: $e');
    }
    return null;
  }
}
