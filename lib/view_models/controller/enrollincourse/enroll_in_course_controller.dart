import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/Courses/all_courses_model.dart';
import '../../../res/routes/routes_name.dart';
import '../profile/user_profile_controller.dart';
import '../userPreferences/user_preferences_screen.dart';

class CourseEnrollmentController extends GetxController {
  final userCoins = Get.find<UserProfileController>();
  final _prefs = UserPreferencesViewmodel();
  static const String baseUrl = ApiUrls.baseUrl;

  final RxMap<String, bool> enrollmentStatus = <String, bool>{}.obs;
  final RxMap<String, bool> loadingStatus = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Refresh user data on initialization to ensure enrolledCourses is up-to-date
    refreshUserData();
  }

  // Refresh user data to ensure enrolledCourses is current
  Future<void> refreshUserData() async {
    try {
      userCoins.userList();
      // developer.log(
      //     'User data refreshed: enrolledCourses=${userCoins.userList.value.enrolledCourses}',
      //     name: 'CourseEnrollmentController');
    } catch (e) {
      // developer.log('Error refreshing user data: $e',
      //     name: 'CourseEnrollmentController');
      Get.snackbar(
        'Error',
        'Failed to refresh user data. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Check if user is enrolled in a course
  bool isUserEnrolled(String courseId) {
    final enrolled =
        userCoins.userList.value.enrolledCourses?.contains(courseId) ?? false;
    return enrolled;
  }

  // Enroll in a course
  Future<void> enrollCourse(Course course) async {
    final courseId = course.id;
    await refreshUserData();
    if (isUserEnrolled(courseId)) {
      Get.snackbar(
        'Info',
        'You are already enrolled in this course.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      Get.toNamed(RouteName.courseVideoScreen, arguments: course);
      return;
    }

    // Check available coins
    final availableCoins = userCoins.userList.value.wallet?.coins ?? 0;
    final requiredCoins = course.coins ?? 0;

    if (availableCoins < requiredCoins) {
      Get.snackbar(
        'Insufficient Coins',
        '$requiredCoins coins require to enroll in this course.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      loadingStatus[courseId] = true;

      final user = await _prefs.getUser();
      if (user == null || user.token.isEmpty) {
        // developer.log('No user token found',
        //     name: 'CourseEnrollmentController');
        Get.snackbar(
          'Authentication Error',
          'Please log in to enroll.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        Get.offNamed(RouteName.loginScreen);
        return;
      }

      final url = '$baseUrl/connect/v1/api/user/course/enroll-course/$courseId';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update enrolled courses
        userCoins.userList();
        enrollmentStatus[courseId] = true;
        Get.snackbar(
          'Success',
          'Successfully enrolled in the course.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        Get.toNamed(RouteName.courseVideoScreen, arguments: course);
      } else if (response.statusCode == 401) {
        Get.snackbar(
          'Session Expired',
          'Please log in again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        await _prefs.removeUser();
        Get.offNamed(RouteName.loginScreen);
      } else if (response.statusCode == 400) {
        String errorMessage = 'Failed to enroll: Invalid request.';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          // developer.log('Failed to parse error response: $e',
          //     name: 'CourseEnrollmentController');
        }
        Get.snackbar(
          'Info',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        String errorMessage = 'Failed to enroll in the course.';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          // developer.log('Failed to parse error response: $e',
          //     name: 'CourseEnrollmentController');
        }
        Get.snackbar(
          'Info',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (error) {
      String errorMessage = error.toString();
      if (errorMessage.contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (errorMessage.contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again later.';
      } else if (errorMessage.contains('FormatException')) {
        errorMessage = 'Unexpected server response. Please contact support.';
      }
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      loadingStatus[courseId] = false;
    }
  }
}
