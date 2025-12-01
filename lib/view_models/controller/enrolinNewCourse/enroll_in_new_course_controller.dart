import 'dart:convert';
import 'package:get/get.dart';

import '../../../data/response/status.dart';
import '../../../repository/EnrolinNewCourse/enroll_in_course_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class EnrollCourseController extends GetxController {
  final _api = EnrollInCourseRepository();
  final userPreferences = UserPreferencesViewmodel();

  var rxRequestStatus = Status.COMPLETED.obs;
  var successMessage = "".obs;
  var errorMessage = "".obs;
  var isEnrolled = false.obs;

  Future<void> enrollCourse(String courseId) async {
    rxRequestStatus.value = Status.LOADING;
    try {
      final token = await userPreferences.getToken();

      final result = await _api.enrollInCourse(courseId, token!);

      if (result != null) {
        if (result["message"] == "Already enrolled in this course") {
          isEnrolled.value = true;
          successMessage.value = result["message"];
        } else {
          isEnrolled.value = true;
          successMessage.value = result["message"] ?? "Successfully Enrolled!";
        }
        rxRequestStatus.value = Status.COMPLETED;
      }
    } catch (e) {
      // Try to decode API error response
      String msg = "Unexpected error occurred";
      try {
        final err = jsonDecode(e.toString());
        if (err["message"] != null) {
          msg = err["message"];
        }
      } catch (_) {
        msg = e.toString(); // fallback
      }

      errorMessage.value = msg;
      rxRequestStatus.value = Status.ERROR;
    }
  }
}
