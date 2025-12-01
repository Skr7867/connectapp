import 'dart:developer';
import 'dart:io';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../repository/CREATORPANEL/CreateCourseGroup/create_course_group_repository.dart';
import '../../controller/userPreferences/user_preferences_screen.dart';
import '../../../data/response/status.dart';

class CreateCourseGroupController extends GetxController {
  final _api = CreateCourseGroupRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.ERROR.obs;
  final error = ''.obs;
  final groupNameController = TextEditingController().obs;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setGroupName(String value) => groupNameController.value.text = value;

  Future<void> createCourseGroup(String courseId, File? avatarFile) async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        log("❌ Token missing. Cannot create group.");
        return;
      }

      final data = {
        'courseId': courseId,
        'name': groupNameController.value.text,
      };

      log("Creating group with data: $data, avatar: ${avatarFile?.path}");

      final response = await _api.createCourseGroup(
        data,
        token: loginData.token,
        avatarFile: avatarFile,
      );

      log("Parsed API Response: $response");

      if (response is Map && response.containsKey('group')) {
        final group = response['group'];
        final members = group['members'];

        if (members is List && members.isNotEmpty) {
          final userId = members[0]['userId'];
          log("✅ First member userId: $userId");
        }

        Utils.snackBar(
          'Group created successfully',
          'Success',
        );
        setRxRequestStatus(Status.COMPLETED);
        Get.back();
      } else {
        Utils.snackBar(
          'Group created, but unexpected response format',
          'Success',
        );
        setRxRequestStatus(Status.COMPLETED);
      }
    } catch (error, stackTrace) {
      log("❌ API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
      Utils.snackBar(
        error.toString(),
        'Error',
      );
    }
  }
}
