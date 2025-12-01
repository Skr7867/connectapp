import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/CourseProgress/course_progress_model.dart';
import '../../../repository/CourseProgress/course_progress_repository.dart';
import '../../../res/routes/routes_name.dart';
import '../userPreferences/user_preferences_screen.dart';

class CourseProgressController extends GetxController {
  final CourseProgressRepository _repository = CourseProgressRepository();
  final UserPreferencesViewmodel _prefs = UserPreferencesViewmodel();

  final RxMap<String, CourseProgressModel> courseProgressMap =
      RxMap<String, CourseProgressModel>({});
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> fetchCourseProgress(String courseId) async {
    if (courseProgressMap.containsKey(courseId)) {
      // developer.log('Course progress for $courseId already cached',
      //     name: 'CourseProgressController');
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final user = await _prefs.getUser();
      if (user == null || user.token.isEmpty) {
        Get.snackbar(
          'Authentication',
          'Please log in to view course progress.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.offNamed(RouteName.loginScreen);
        return;
      }

      // final url =
      //     '${ApiUrls.baseUrl}/connect/v1/api/user/course/progress/$courseId';
      // // developer.log('Fetching course progress, url: $url',
      // //     name: 'CourseProgressController');

      final response = await _repository.courseProgress(user.token, courseId);
      courseProgressMap[courseId] = response;

      // developer.log('Course Progress for $courseId: ${response.toJson()}',
      //     name: 'CourseProgressController');

      if (response.percentageCompleted != null) {
        // developer.log(
        //     'Course $courseId progress: ${response.percentageCompleted}% completed',
        //     name: 'CourseProgressController');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      // developer.log('Course Progress Error for $courseId: $e',
      //     name: 'CourseProgressController');

      String message;
      if (e.toString().contains('SocketException')) {
        message = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('TimeoutException')) {
        message = 'Request timed out. Please try again later.';
      } else if (e.toString().contains('401')) {
        message = 'Session expired. Please log in again.';
        await _prefs.removeUser();
        Get.offNamed(RouteName.loginScreen);
        return;
      } else if (e.toString().contains('404')) {
        message = 'Course progress not found';
      } else {
        message = 'Failed to load course progress for course ID: ';
      }
      log('Fialed to load course for $message');
    } finally {
      isLoading.value = false;
    }
  }
}
