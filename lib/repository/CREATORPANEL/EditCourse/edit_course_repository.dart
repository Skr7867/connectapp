import 'dart:io';
import 'package:connectapp/data/network/base_api_services.dart';
import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:http/http.dart' as http;
import '../../../view_models/controller/userPreferences/user_preferences_screen.dart';

class EditCourseRepository {
  final BaseApiServices apiServices = NetworkApiServices();
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();

  Future<http.Response> updateCourseApi(
    String courseId,
    Map<String, dynamic> data,
    File? thumbnailFile,
  ) async {
    try {
      // Get the token from shared preferences
      final token = await _userPreferences.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${ApiUrls.editCourseApi}/$courseId'),
      );

      // Add fields
      request.fields['title'] = data['title'];
      request.fields['description'] = data['description'];
      request.fields['language'] = data['language'];
      // Send tags as comma-separated string
      request.fields['tags'] = (data['tags'] as List<String>).join(',');
      request.fields['xpOnStart'] = data['xpOnStart'].toString();
      request.fields['xpOnLessonCompletion'] =
          data['xpOnLessonCompletion'].toString();
      request.fields['xpOnCompletion'] = data['xpOnCompletion'].toString();
      request.fields['xpPerPerfectQuiz'] = data['xpPerPerfectQuiz'].toString();
      request.fields['coins'] = data['coins'].toString();
      request.fields['isPublished'] = data['isPublished'].toString();

      // Add thumbnail file if provided
      if (thumbnailFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'thumbnail',
            thumbnailFile.path,
          ),
        );
      }

      // Add headers with authorization token
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
