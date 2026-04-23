import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../model_ps/freesound_model.dart';

class FreesoundService {
  final String _apiKey = dotenv.env['FREESOUND_API_KEY'] ?? '';
  final String _baseUrl = 'https://freesound.org/apiv2/search/text/';

  Future<FreesoundResponse> searchSounds({
    required String query,
    int page = 1,
  }) async {
    final url = Uri.parse(
      '$_baseUrl?query=$query&page=$page&page_size=10&fields=id,name,previews,description,duration,images',
    );

    final response = await http.get(
      url,
      headers: {'Authorization': 'Token $_apiKey'},
    );

    if (response.statusCode == 200) {
      return FreesoundResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar sonidos');
    }
  }
}
