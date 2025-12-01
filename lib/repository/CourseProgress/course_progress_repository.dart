import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

import '../../models/CourseProgress/course_progress_model.dart';
import '../../res/api_urls/api_urls.dart';

class CourseProgressRepository {
  Future<CourseProgressModel> courseProgress(
      String token, String courseId) async {
    final url =
        '${ApiUrls.baseUrl}/connect/v1/api/user/course/progress/$courseId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return CourseProgressModel.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to fetch course progress: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      developer.log(
          'CourseProgressRepository: Error fetching progress for course $courseId: $e',
          name: 'CourseProgressRepository');
      rethrow;
    }
  }
}
