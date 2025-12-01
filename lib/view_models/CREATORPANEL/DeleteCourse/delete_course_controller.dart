import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:connectapp/view_models/CREATORPANEL/GetAllCreatorCourses/get_all_creater_courses_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../controller/userPreferences/user_preferences_screen.dart';

class DeleteCourseController extends GetxController {
  final RxBool isDeleting = false.obs;
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();

  @override
  void onInit() {
    super.onInit();
    _userPreferences.init();
  }

  Future<bool> deleteCourse(String courseId) async {
    try {
      isDeleting.value = true;

      final user = await _userPreferences.getUser();
      final String? token = user?.token;

      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'No authentication token found. Please log in.');
        Get.offAllNamed('/loginscreen');
        return false;
      }

      final url = Uri.parse(
          '${ApiUrls.baseUrl}/connect/v1/api/creator/course/delete-course/$courseId');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonDecode(response.body);
        Utils.snackBar('Course deleted successfully', 'Success');

        // Refresh spaces list
        final fetchController = Get.find<GetAllCreatorCoursesController>();
        await fetchController.creatorCourseApi();

        return true;
      } else {
        Utils.snackBar(
            'Error', 'Failed to delete course: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      Utils.snackBar('Error', 'An error occurred: $e');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }
}
