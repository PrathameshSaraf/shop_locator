import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shop_model.dart';

class ShopRepository {
  final String _apiKey = 'AIzaSyCmgUnE0Iq7janf4NCyBaGLlpQ5KRonysA';
  final String _baseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  Future<List<Shop>> fetchNearbyShops(
    double lat,
    double lng, {
    String? type,
  }) async {
    final String url =
        '$_baseUrl?location=$lat,$lng&radius=2000&type=${type ?? 'store'}&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
          final List results = data['results'];
          return results.map((e) => Shop.fromJson(e)).toList();
        } else {
          throw Exception(
            'API Error: ${data['status']} - ${data['error_message'] ?? ''}',
          );
        }
      } else {
        throw Exception('Failed to load shops');
      }
    } catch (e) {
      throw Exception('Error fetching shops: $e');
    }
  }
}
