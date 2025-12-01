import 'dart:async';

import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectapp/view_models/CREATORPANEL/FetchCreatorSpace/fetch_creator_space_controller.dart';
import '../../controller/userPreferences/user_preferences_screen.dart';

class EndMeetingsController extends GetxController {
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _userPreferences.init();
  }

  Future<void> endMeeting(String spaceId) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Fetch token
      final user = await _userPreferences.getUser();
      final String? token = user?.token;

      if (token == null || token.isEmpty) {
        error.value = 'No authentication token found. Please log in again.';
        Get.snackbar(
          'Error',
          error.value,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        Get.offAllNamed('/login');
        return;
      }

      // Construct API URL
      final url =
          Uri.parse('${ApiUrls.baseUrl}/connect/v1/api/space/end/$spaceId');

      // Make PATCH request
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseJson = jsonDecode(response.body);
          Get.snackbar(
            'Success',
            responseJson['message'] ?? 'Meeting started successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Refresh spaces list to update status
          final fetchController = Get.find<FetchCreatorSpaceController>();
          await fetchController.fetchSpaces();

          // Optional: Navigate to meeting room if API returns a room URL
          // if (responseJson['data']?['roomUrl'] != null) {
          //   Get.toNamed('/meetingRoom', arguments: {'roomUrl': responseJson['data']['roomUrl']});
          // }
        } catch (e) {
          throw 'Failed to parse response: $e';
        }
      } else {
        String errorMessage;
        if (response.body.startsWith('<!DOCTYPE html') ||
            response.body.contains('<html')) {
          errorMessage =
              'Server returned an unexpected HTML response. Please contact support.';
        } else {
          try {
            final responseJson = jsonDecode(response.body);
            errorMessage =
                responseJson['message'] ?? 'Error: ${response.statusCode}';
          } catch (e) {
            errorMessage =
                'Failed to parse error response: ${response.statusCode}';
          }
        }
        throw errorMessage;
      }
    } on SocketException {
      error.value = 'No internet connection. Please check your network.';
      Get.snackbar(
        'Error',
        error.value,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } on TimeoutException {
      error.value = 'Request timed out. Please try again later.';
      Get.snackbar(
        'Error',
        error.value,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } on FormatException catch (e) {
      error.value = 'Invalid response format: $e';
      Get.snackbar(
        'Error',
        error.value,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = 'Failed to end meeting: $e';
      Get.snackbar(
        'Error',
        error.value,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      log('Error end meeting: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
