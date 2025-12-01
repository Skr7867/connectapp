import 'dart:developer';
import 'dart:io';
import 'package:connectapp/data/appexception/app_exception.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:http/http.dart' as http;
import '../../../data/network/network_api_services.dart';

class LessonRepository {
  final NetworkApiServices _apiServices = NetworkApiServices();

  // Create a lesson (with optional video file)
  Future<dynamic> createLesson({
    required String courseId,
    required String sectionId,
    required Map<String, dynamic> lessonData,
    File? videoFile,
    String? token,
  }) async {
    try {
      final String url =
          '${ApiUrls.baseUrl}/connect/v1/api/creator/course/$courseId/section/$sectionId/add-lesson';

      if (videoFile != null) {
        // Prepare multipart request with lesson data and video file
        final String fileName = videoFile.path.split('/').last;
        final data = {
          ...lessonData.map((key, value) => MapEntry(
              key,
              value
                  .toString())), // Convert lesson data to strings for form fields
          'video': await http.MultipartFile.fromPath(
            'video', // Field name expected by the server
            videoFile.path,
            filename: fileName,
          ),
        };

        final response = await _apiServices.postApi(
          data,
          url,
          token: token,
          isFileUpload: true,
        );
        return response;
      } else {
        // Send JSON request without video
        final response = await _apiServices.postApi(
          lessonData,
          url,
          token: token,
        );
        return response;
      }
    } catch (e) {
      log('Error creating lesson: $e');
      if (e is AppExceptions) {
        rethrow;
      }
      throw FetchDataException('Failed to create lesson: $e');
    }
  }
}
