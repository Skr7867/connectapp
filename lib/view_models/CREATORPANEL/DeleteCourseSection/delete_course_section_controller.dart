import 'dart:developer';
import 'package:connectapp/repository/CREATORPANEL/DeleteCourseSection/delete_course_section_repository.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:get/get.dart';
import '../../controller/userPreferences/user_preferences_screen.dart';

class DeleteCourseSectionController extends GetxController {
  final _api = DeleteCourseSectionRepository();
  final _prefs = UserPreferencesViewmodel();

  final isDeleting = false.obs;
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setIsDeleting(bool value) => isDeleting.value = value;

  Future<bool> deleteCourseSection(String courseId, String sectionId) async {
    setIsDeleting(true);
    setError('');

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        log("Token missing. Cannot delete course section.");
        Get.snackbar('Error', 'User not authenticated. Please log in.');
        setIsDeleting(false);
        return false;
      }

      log("Deleting section with TOKEN: ${loginData.token}, Course ID: $courseId, Section ID: $sectionId");

      await _api.deleteCourseSection(loginData.token, courseId, sectionId);

      setIsDeleting(false);
      Utils.snackBar(
        'Course section deleted successfully.',
        'Success',
      );
      return true;
    } catch (error, stackTrace) {
      log("Delete API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      Get.snackbar('Error', error.toString());
      setIsDeleting(false);
      return false;
    }
  }
}
