import 'dart:developer';
import 'package:connectapp/data/network/base_api_services.dart';
import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:get/get.dart';

class EditCourseSectionController extends GetxController {
  final BaseApiServices _apiServices = NetworkApiServices();
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();
  final isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    _userPreferences.init(); // Initialize SharedPreferences
  }

  Future<bool> updateCourseSection(
      String courseId, String sectionId, String title) async {
    if (title.trim().isEmpty) {
      Utils.snackBar('Error', 'Section title cannot be empty');
      return false;
    }

    isUpdating.value = true;
    try {
      final token = await _userPreferences.getToken();
      if (token == null) {
        log('No token found');
        Utils.snackBar('Error', 'You are not authenticated. Please log in.');
        return false;
      }

      // Corrected URL: Removed 'update-course' segment
      final url =
          '${ApiUrls.baseUrl}/connect/v1/api/creator/course/$courseId/section/update/$sectionId';
      final data = {'title': title.trim()};

      log('Updating section with URL: $url');
      log('Payload: $data');

      final response = await _apiServices.patchApi(
        data,
        url,
        token: token,
      );

      if (response['status'] == 'success') {
        Utils.snackBar(
          'Section updated successfully',
          'Success',
        );
        return true;
      } else {
        log('Update section failed: ${response['message']}');
        Utils.snackBar(response['message'], 'Success');
        return false;
      }
    } catch (e) {
      log('Error updating section: $e');
      if (e.toString().contains('FormatException')) {
        Utils.snackBar(
          'Server returned an unexpected response. Please check the API endpoint.',
          'Error',
        );
      } else {
        Utils.snackBar('Error', 'Failed to update section: $e');
      }
      return false;
    } finally {
      isUpdating.value = false;
    }
  }
}
