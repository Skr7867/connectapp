import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../res/api_urls/api_urls.dart';

class CreateCourseGroupRepository {
  Future<dynamic> createCourseGroup(
    Map<String, dynamic> data, {
    String? token,
    File? avatarFile,
  }) async {
    final uri = Uri.parse(ApiUrls.createCourseGroupApi);
    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (avatarFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('groupAvatar', avatarFile.path),
      );
    }

    log("Sending request to ${ApiUrls.createCourseGroupApi} with data: ${request.fields}, files: ${request.files}");

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    log("Raw API Response: $responseBody");

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final parsed = jsonDecode(responseBody);
        return parsed;
      } catch (e) {
        log(" Failed to parse JSON: $e");
        throw Exception("Invalid response format: $responseBody");
      }
    } else {
      throw Exception(responseBody);
    }
  }
}
