import 'dart:developer';
import 'package:connectapp/data/network/base_api_services.dart';
import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:get/get.dart';

class EditLessionController extends GetxController {
  final BaseApiServices _apiServices = NetworkApiServices();
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();
  final isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    _userPreferences.init();
  }

  Future<bool> updateLesson(
    String courseId,
    String sectionId,
    String lessonId,
    String title,
    String description,
    String contentType,
    String textContent,
  ) async {
    if (title.trim().isEmpty) {
      Utils.snackBar(
        'Lesson title cannot be empty',
        'Error',
      );
      return false;
    }

    isUpdating.value = true;
    try {
      final token = await _userPreferences.getToken();
      if (token == null) {
        log('No token found');
        Utils.snackBar(
          'You are not authenticated. Please log in.',
          'Error',
        );
        return false;
      }

      final url =
          '${ApiUrls.baseUrl}/connect/v1/api/creator/course/$courseId/section/$sectionId/update-lesson/$lessonId';
      final data = {
        'title': title.trim(),
        'description': description.trim(),
        'contentType': contentType.toLowerCase(),
        'textContent': contentType == 'Text' ? textContent.trim() : '',
      };

      log('Updating lesson with URL: $url');
      log('Payload: $data');

      final response = await _apiServices.patchApi(
        data,
        url,
        token: token,
      );

      if (response['message'] == 'Lesson updated successfully') {
        Utils.snackBar('Lesson updated successfully', 'Success');
        Get.toNamed(RouteName.createCourseSectionScreen);
        return true;
      } else {
        log('Update lesson failed: ${response['message']}');
        Utils.snackBar(response['message'], 'Success');
        Get.toNamed(RouteName.createCourseSectionScreen);
        return false;
      }
    } catch (e) {
      log('Error updating lesson: $e');
      if (e.toString().contains('FormatException')) {
        Utils.snackBar(
          'Server returned an unexpected response. Please check the API endpoint.',
          'Error',
        );
      } else {
        Utils.snackBar('Error', 'Failed to update lesson: $e');
      }
      return false;
    } finally {
      isUpdating.value = false;
    }
  }
}
