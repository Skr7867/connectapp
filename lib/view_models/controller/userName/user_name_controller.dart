import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

import '../../../res/api_urls/api_urls.dart';

class UserNameController extends GetxController {
  final username = ''.obs;
  final isUsernameAvailable = Rx<bool?>(null);
  final isCheckingUsername = false.obs;
  final usernameController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    usernameController.text = username.value;
    usernameController.addListener(() {
      if (usernameController.text != username.value) {
        updateUsername(usernameController.text);
      }
    });
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    usernameController.dispose();
    super.onClose();
  }

  void updateUsername(String value) {
    username.value = value;
    isUsernameAvailable.value = null;

    _debounceTimer?.cancel();

    if (value.length >= 3) {
      _debounceTimer = Timer(const Duration(seconds: 1), () {
        checkUsernameAvailability();
      });
    }
  }

  Future<void> checkUsernameAvailability() async {
    isCheckingUsername.value = true;
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/redis/check-username?username=${username.value}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        isUsernameAvailable.value = data['available'] as bool?;
        log(username.value);
      } else {
        isUsernameAvailable.value = null;
      }
    } catch (error) {
      isUsernameAvailable.value = null;
    } finally {
      isCheckingUsername.value = false;
    }
  }
}
