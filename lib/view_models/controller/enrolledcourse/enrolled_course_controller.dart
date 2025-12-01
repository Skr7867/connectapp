import 'package:connectapp/models/EnrolledCourses/enrolled_courses_model.dart';
import 'package:connectapp/repository/EnrolledCourse/enrolled_course_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/response/status.dart';
import '../../../res/routes/routes_name.dart';
import '../userPreferences/user_preferences_screen.dart';

class EnrolledCourseController extends GetxController {
  final _api = EnrolledCourseRepository();
  final _prefs = UserPreferencesViewmodel();
  final rxRequestStatus = Status.LOADING.obs;
  final enrolledCourses = EnrolledCoursesModel().obs;
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setUserList(EnrolledCoursesModel value) => enrolledCourses.value = value;

  @override
  void onInit() {
    super.onInit();
    userListApi();
  }

  Future<void> userListApi() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        Get.snackbar(
          'Authentication Error',
          'Please log in to view enrolled courses.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.offNamed(RouteName.loginScreen);
        return;
      }

      // log("TOKEN: ${loginData.token}", name: 'EnrolledCourseController');

      final value = await _api.enrolledCourses(loginData.token);
      // log("API Response: ${value.toJson()}", name: 'EnrolledCourseController');
      setRxRequestStatus(Status.COMPLETED);
      setUserList(value);
    } catch (error) {
      // log("API Error: $error",
      //     name: 'EnrolledCourseController', stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);

      String message;
      if (error.toString().contains('SocketException')) {
        message = 'No internet connection. Please check your network.';
      } else if (error.toString().contains('TimeoutException')) {
        message = 'Request timed out. Please try again later.';
      } else if (error.toString().contains('401')) {
        message = 'Session expired. Please log in again.';
        await _prefs.removeUser();
        Get.offNamed(RouteName.loginScreen);
        return;
      } else {
        message = 'Failed to load enrolled courses.';
      }

      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> refreshApi() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        Get.snackbar(
          'Authentication Error',
          'Please log in to view enrolled courses.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.offNamed(RouteName.loginScreen);
        return;
      }

      // log("Refresh TOKEN: ${loginData.token}",
      //     name: 'EnrolledCourseController');

      final value = await _api.enrolledCourses(loginData.token);
      // log("API Response: ${value.toJson()}", name: 'EnrolledCourseController');
      setRxRequestStatus(Status.COMPLETED);
      setUserList(value);
    } catch (error) {
      // log("Refresh API Error: $error",
      //     name: 'EnrolledCourseController', stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);

      String message;
      if (error.toString().contains('SocketException')) {
        message = 'No internet connection. Please check your network.';
      } else if (error.toString().contains('TimeoutException')) {
        message = 'Request timed out. Please try again later.';
      } else if (error.toString().contains('401')) {
        message = 'Session expired. Please log in again.';
        await _prefs.removeUser();
        Get.offNamed(RouteName.loginScreen);
        return;
      } else {
        message = 'Failed to load enrolled courses.';
      }

      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
