import 'dart:convert';
import 'package:http/http.dart' as http;

class TravelService {
  static const String _baseUrl = 'http://10.42.0.24:5000'; // ✅ Your backend IPv4

  Future<List<dynamic>> getFlights(String origin, String destination, String date) async {
    final url = Uri.parse('$_baseUrl/api/travel/flights?origin=$origin&destination=$destination&date=$date');
    print("🔍 Fetching flights from: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Flights fetched: ${data.length}");

      // ✅ Your backend returns { flights: [...] } → so extract the list
      if (data is Map && data.containsKey('flights')) {
        return List.from(data['flights']);
      }

      // ✅ If backend directly sends list
      if (data is List) return data;

      return [];
    } else {
      print("❌ Flight fetch failed: ${response.statusCode}");
      throw Exception('Failed to load flights');
    }
  }

  Future<List<dynamic>> getTrains(String from, String to, String date) async {
    final url = Uri.parse('$_baseUrl/api/travel/trains?from=$from&to=$to&date=$date');
    print("🚆 Fetching trains from: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Trains fetched: ${data.length}");

      if (data is List) return data;

      if (data is Map && data.containsKey('data')) {
        return List.from(data['data']);
      }

      return [];
    } else {
      print("❌ Train fetch failed: ${response.statusCode}");
      throw Exception('Failed to load trains');
    }
  }

  Future<List<dynamic>> getBuses(String from, String to, String date) async {
    final url = Uri.parse('$_baseUrl/api/travel/buses?from=$from&to=$to&date=$date');
    print("🚌 Fetching buses from: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Buses fetched: ${data.length}");

      if (data is List) return data;

      if (data is Map && data.containsKey('data')) {
        return List.from(data['data']);
      }

      return [];
    } else {
      print("❌ Bus fetch failed: ${response.statusCode}");
      throw Exception('Failed to load buses');
    }

  }
}
