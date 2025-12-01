import 'dart:developer';
import 'dart:io';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../repository/CREATORPANEL/CreateCourse/create_course_repository.dart';
import '../../../res/routes/routes_name.dart';
import '../../controller/userPreferences/user_preferences_screen.dart';

class CreateCourseController extends GetxController {
  final Rx<File?> thumbnailImage = Rx<File?>(null);

  void setThumbnail(File file) {
    thumbnailImage.value = file;
  }

  void clearThumbnail() {
    thumbnailImage.value = null;
  }

  final CreateCourseRepository _repository = CreateCourseRepository();
  final UserPreferencesViewmodel _prefs = UserPreferencesViewmodel();

  RxBool isLoading = false.obs;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final languageController = TextEditingController();
  final tagsController = TextEditingController();
  final xpOnStartController = TextEditingController();
  final xpOnLessonCompletionController = TextEditingController();
  final xpOnCompletionController = TextEditingController();
  final xpPerPerfectQuizController = TextEditingController();
  final coinsController = TextEditingController();
  final isPublished = false.obs;

  final apiResponse = {}.obs;

  Future<void> createCourse() async {
    isLoading.value = true;

    try {
      await _prefs.init();
      final token = await _prefs.getToken();

      if (token == null) {
        Utils.snackBar(
          "User token not found. Please log in again.",
          "Error",
        );
        isLoading.value = false;
        return;
      }

      final Map<String, dynamic> data = {
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "language": languageController.text.trim(),
        "tags": tagsController.text.trim(),
        "xpOnStart": int.tryParse(xpOnStartController.text) ?? 0,
        "xpOnLessonCompletion":
            int.tryParse(xpOnLessonCompletionController.text) ?? 0,
        "xpOnCompletion": int.tryParse(xpOnCompletionController.text) ?? 0,
        "xpPerPerfectQuiz": int.tryParse(xpPerPerfectQuizController.text) ?? 0,
        "coins": int.tryParse(coinsController.text) ?? 0,
        "isPublished": isPublished.value.toString(),
      };

      final response = await _repository.createCourse(
        data,
        token: token,
        thumbnailFile: thumbnailImage.value,
      );

      apiResponse.value = response;
      Utils.snackBar(
        "Course created request send successfully",
        "Success",
      );
      Get.toNamed(RouteName.creatorCourseManagementScreen);
    } catch (e) {
      log(" Error in createCourse: $e");
      Utils.snackBar(
        e.toString(),
        " Error",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Dispose all controllers
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    languageController.dispose();
    tagsController.dispose();
    xpOnStartController.dispose();
    xpOnLessonCompletionController.dispose();
    xpOnCompletionController.dispose();
    xpPerPerfectQuizController.dispose();
    coinsController.dispose();
    super.onClose();
  }
}
