import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectapp/models/CREATORPANEL/CreatorCourses/get_all_creator_courses_model.dart';
import 'package:connectapp/repository/CREATORPANEL/EditCourse/edit_course_repository.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../GetAllCreatorCourses/get_all_creater_courses_controller.dart';

class EditCourseController extends GetxController {
  final _api = EditCourseRepository();

  // Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final tagsController = TextEditingController();
  final xpOnStartController = TextEditingController();
  final xpOnLessonCompletionController = TextEditingController();
  final xpOnCompletionController = TextEditingController();
  final xpPerPerfectQuizController = TextEditingController();
  final coinsController = TextEditingController();

  // Variables
  final isLoading = false.obs;
  final isPublished = false.obs;
  final selectedLanguage = ''.obs;
  File? thumbnailFile; // For new image uploads
  String? thumbnailUrl; // For existing network images
  String? courseId;

  // Initialize course data
  void initializeCourse(GetAllCreatorCoursesModel course) {
    courseId = course.sId;
    titleController.text = course.title ?? '';
    descriptionController.text = course.description ?? '';

    // Handle potentially nested tags
    List<String> cleanTags = _cleanTags(course.tags);
    tagsController.text = cleanTags.join(', ');

    xpOnStartController.text = course.xpOnStart?.toString() ?? '0';
    xpOnLessonCompletionController.text =
        course.xpOnLessonCompletion?.toString() ?? '0';
    xpOnCompletionController.text = course.xpOnCompletion?.toString() ?? '0';
    xpPerPerfectQuizController.text =
        course.xpPerPerfectQuiz?.toString() ?? '0';
    coinsController.text = course.coins?.toString() ?? '0';
    isPublished.value = course.isPublished ?? false;
    selectedLanguage.value = course.language ?? '';
    thumbnailUrl = course.thumbnail; // Store existing thumbnail URL
    thumbnailFile = null; // Clear any previous file selection
  }

  List<String> _cleanTags(dynamic tags) {
    try {
      if (tags == null) return [];

      if (tags is List) {
        while (tags is List && tags.isNotEmpty && tags[0] is! String) {
          tags = tags[0];
          if (tags is String) {
            tags = jsonDecode(tags);
          }
        }

        if (tags is List) {
          return tags.cast<String>().where((tag) => tag.isNotEmpty).toList();
        }
      }

      if (tags is String) {
        try {
          final parsed = jsonDecode(tags);
          if (parsed is List) {
            return parsed
                .cast<String>()
                .where((tag) => tag.isNotEmpty)
                .toList();
          }
        } catch (e) {
          return tags
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  void setThumbnail(dynamic imageSource) {
    if (imageSource is File) {
      thumbnailFile = imageSource;
      thumbnailUrl = null;
    } else if (imageSource is String) {
      thumbnailUrl = imageSource;
      thumbnailFile = null;
    }
    update();
  }

  Future<void> updateCourse() async {
    try {
      isLoading.value = true;

      if (titleController.text.trim().isEmpty) {
        throw Exception('Title is required');
      }
      if (descriptionController.text.trim().isEmpty) {
        throw Exception('Description is required');
      }
      if (selectedLanguage.value.isEmpty) {
        throw Exception('Language is required');
      }

      // Prepare request data
      final requestData = {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'language': selectedLanguage.value,
        'tags': _processTags(tagsController.text),
        'xpOnStart': int.tryParse(xpOnStartController.text) ?? 0,
        'xpOnLessonCompletion':
            int.tryParse(xpOnLessonCompletionController.text) ?? 0,
        'xpOnCompletion': int.tryParse(xpOnCompletionController.text) ?? 0,
        'xpPerPerfectQuiz': int.tryParse(xpPerPerfectQuizController.text) ?? 0,
        'coins': int.tryParse(coinsController.text) ?? 0,
        'isPublished': isPublished.value,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      };

      log('Tags sent to API: ${requestData['tags']}');

      if (courseId == null || courseId!.isEmpty) {
        throw Exception('Course ID is missing');
      }

      // Call API
      final response = await _api.updateCourseApi(
        courseId!,
        requestData,
        thumbnailFile,
      );

      if (response.statusCode == 200) {
        Utils.snackBar('Course updated successfully', 'Success');

        final coursesController = Get.find<GetAllCreatorCoursesController>();
        await coursesController.refreshApi();

        Get.offNamed(RouteName.creatorCourseManagementScreen);
      } else if (response.statusCode == 401) {
        Utils.snackBar('Error', 'Session expired. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to update course: ${response.statusCode}');
      }
    } catch (e) {
      log('Error updating course: $e');
      Utils.snackBar('Error', e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  List<String> _processTags(String tagsString) {
    return tagsString
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    xpOnStartController.dispose();
    xpOnLessonCompletionController.dispose();
    xpOnCompletionController.dispose();
    xpPerPerfectQuizController.dispose();
    coinsController.dispose();
    super.onClose();
  }
}
