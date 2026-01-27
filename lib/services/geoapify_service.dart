import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeoapifyService {
  final String _geoApiKey = dotenv.env['GEOAPIFY_API_KEY']!;
  final String _routeApiKey = dotenv.env['OPENROUTESERVICE_API_KEY']!;

  /// 🔍 Search nearby hotels or restaurants
  Future<List<Map<String, dynamic>>> nearbySearch({
    required double lat,
    required double lon,
    required String type, // "hotel" or "restaurant"
  }) async {
    final categories = type == 'hotel'
        ? 'accommodation.hotel'
        : 'catering.restaurant';

    final url =
        'https://api.geoapify.com/v2/places?categories=$categories&filter=circle:$lon,$lat,2000&limit=20&apiKey=$_geoApiKey';

    final uri = Uri.parse(url);
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data['features'] == null) return [];

      final features = (data['features'] as List)
          .map((f) => f['properties'] as Map<String, dynamic>)
          .toList();

      return features;
    } else {
      print("Geoapify API error: ${res.statusCode} → ${res.body}");
      throw Exception('Failed to load places');
    }
  }

  /// 🚗 Generate OpenRouteService directions URL (to open in browser)
  String getDirectionsUrl(
      double startLat, double startLon, double endLat, double endLon) {
    return 'https://maps.openrouteservice.org/directions?n1=$startLat&n2=$startLon&n3=12&a=$startLat,$startLon,$endLat,$endLon&b=0&api_key=$_routeApiKey';
  }
}
