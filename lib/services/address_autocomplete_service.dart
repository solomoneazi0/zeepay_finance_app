import 'dart:convert';

import 'package:http/http.dart' as http;

class AddressAutocompleteService {
  static const String _host = 'nominatim.openstreetmap.org';
  static const String _searchPath = '/search';
  static const int _defaultLimit = 8;

  Future<List<String>> fetchSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final uri = Uri.https(_host, _searchPath, {
      'q': trimmed,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '$_defaultLimit',
    });

    try {
      final response = await http.get(
        uri,
        headers: const {
          // Nominatim requests identifying User-Agent for fair use.
          'User-Agent': 'zepay_app/1.0 (support@zepay.local)',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) return const [];
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return const [];

      final seen = <String>{};
      final results = <String>[];

      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final display = item['display_name'];
          if (display is String && display.isNotEmpty && seen.add(display)) {
            results.add(display);
          }
        }
      }

      return results;
    } catch (_) {
      return const [];
    }
  }
}

