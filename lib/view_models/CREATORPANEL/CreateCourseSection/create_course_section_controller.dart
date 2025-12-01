import 'dart:developer';
import 'package:connectapp/utils/utils.dart';
import 'package:get/get.dart';
import '../../../data/appexception/app_exception.dart';
import '../../../repository/CREATORPANEL/CreatorCourseSection/create_course_section_repository.dart';
import '../../controller/userPreferences/user_preferences_screen.dart';

class CreateCourseSectionController extends GetxController {
  final _api = CreateCourseSectionRepository();
  final _prefs = UserPreferencesViewmodel();

  final isCreating = false.obs;
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setIsCreating(bool value) => isCreating.value = value;

  Future<bool> createCourseSection(String courseId, String title) async {
    if (title.isEmpty) {
      setError("Section title cannot be empty.");
      Utils.snackBar('Please enter a section title.', 'Error');
      log("Error: Empty section title");
      return false;
    }

    setIsCreating(true);
    setError('');

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        log("Token missing. Cannot create course section.");
        Utils.snackBar('User not authenticated. Please log in.', 'Error');
        setIsCreating(false);
        return false;
      }

      log("Creating section with TOKEN: ${loginData.token}, Course ID: $courseId, Title: $title");

      final response =
          await _api.createCourseSection(loginData.token, courseId, title);
      log("Create API Response: $response");
      setIsCreating(false);
      Utils.snackBar('Course section created successfully.', 'Success');
      return true;
    } catch (error, stackTrace) {
      log("Create API Error: $error", stackTrace: stackTrace);
      String errorMessage = error.toString();
      if (error is FetchDataException) {
        errorMessage = errorMessage;
      }
      setError(errorMessage);
      Utils.snackBar(errorMessage, 'Error');
      setIsCreating(false);
      return false;
    }
  }
}
