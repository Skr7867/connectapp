import 'dart:convert';
import 'dart:developer';
import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:http/http.dart' as http;

class HttpService {
  final String baseUrl = ApiUrls.baseUrl;

  Future<dynamic> getApi(String endpoint, {required String token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    // log('Sending GET to $uri with headers: Bearer $token');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to fetch data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('GET error: $e');
      rethrow;
    }
  }

  Future<dynamic> postApi(String endpoint, Map<String, dynamic> data,
      {required String token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    log('Sending POST to $uri with data: $data, headers: Bearer $token');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to post data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('POST error: $e');
      rethrow;
    }
  }

  Future<dynamic> patchApi(String endpoint, Map<String, dynamic> data,
      {required String token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    log('Sending PATCH to $uri with data: $data, headers: Bearer $token');
    try {
      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to patch data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('PATCH error: $e');
      rethrow;
    }
  }
}
