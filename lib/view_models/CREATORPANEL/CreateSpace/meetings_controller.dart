import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import '../../../repository/CREATORPANEL/CreateSpace/create_space_repository.dart';
import '../../../res/routes/routes_name.dart';
import '../../controller/userPreferences/user_preferences_screen.dart';
import '../FetchCreatorSpace/fetch_creator_space_controller.dart';

class NewMeetingController extends GetxController {
  final TextEditingController topicController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> fromTime = Rxn<TimeOfDay>();
  final Rxn<TimeOfDay> toTime = Rxn<TimeOfDay>();

  final RxBool enableWaitingRoom = false.obs;
  final RxBool autoRecord = false.obs;
  final RxBool isLoading = false.obs;

  final CreateSpaceRepository _createSpaceRepository = CreateSpaceRepository();
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();

  @override
  void onInit() {
    super.onInit();
    _userPreferences.init();
  }

  void pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (picked != null) selectedDate.value = picked;
  }

  void pickTime(BuildContext context, bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (picked != null) {
      if (isFrom) {
        fromTime.value = picked;
      } else {
        toTime.value = picked;
      }
    }
  }

  Future<void> scheduleMeeting() async {
    if (topicController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedDate.value == null ||
        fromTime.value == null) {
      Get.snackbar(
        "Info",
        "Please fill all required fields (topic, description, date, and start time)",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    final user = await _userPreferences.getUser();
    final String? token = user?.token;

    log('Fetched Token: $token');

    if (token == null || token.isEmpty) {
      Get.snackbar(
        "Error",
        "No authentication token found. Please log in again.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      Get.offAllNamed(RouteName.loginScreen);
      return;
    }

    final DateTime startDateTime = DateTime(
      selectedDate.value!.year,
      selectedDate.value!.month,
      selectedDate.value!.day,
      fromTime.value!.hour,
      fromTime.value!.minute,
    );
    final String formattedStartTime =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(startDateTime.toUtc());

    final DateTime? endDateTime = toTime.value != null
        ? DateTime(
            selectedDate.value!.year,
            selectedDate.value!.month,
            selectedDate.value!.day,
            toTime.value!.hour,
            toTime.value!.minute,
          )
        : null;
    final String? formattedEndTime = endDateTime != null
        ? DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(endDateTime.toUtc())
        : null;

    List<String> tags = tagsController.text.isNotEmpty
        ? tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList()
        : [];

    final Map<String, dynamic> data = {
      "title": topicController.text,
      "description": descriptionController.text,
      "startTime": formattedStartTime,
      if (formattedEndTime != null) "endTime": formattedEndTime,
      "tags": tags,
      "enableWaitingRoom": enableWaitingRoom.value,
      "autoRecord": autoRecord.value,
    };

    try {
      await _createSpaceRepository.createSpace(data, token: token);
      Get.snackbar(
        "Success",
        "Meeting scheduled successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh spaces list
      final fetchController = Get.find<FetchCreatorSpaceController>();
      await fetchController.fetchSpaces();

      // Navigate back to MeetingDetailsScreen
      Get.offNamed(RouteName.meetingDetailScreen);
    } catch (e) {
      log('API Error: $e');
      Get.snackbar(
        "Error",
        "Failed to schedule meeting: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    topicController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    super.onClose();
  }
}
