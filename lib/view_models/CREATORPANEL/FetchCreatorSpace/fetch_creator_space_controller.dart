import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';
import '../../../models/CREATORPANEL/FetchCreatorSpace/fetch_creator_space_model.dart';
import '../../../repository/CREATORPANEL/FetchCreatorSpace/fetch_creator_space_repository.dart';
import '../../controller/userPreferences/user_preferences_screen.dart';

class FetchCreatorSpaceController extends GetxController {
  final FetchCreatorSpaceRepository _repository = FetchCreatorSpaceRepository();
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();

  final Rx<FetchCreatorSpaceModel?> spacesData =
      Rx<FetchCreatorSpaceModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _userPreferences.init();
    fetchSpaces();
  }

  Future<void> fetchSpaces() async {
    try {
      isLoading.value = true;
      error.value = '';

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

      final FetchCreatorSpaceModel fetchedSpaces =
          await _repository.creatorSpace(token);
      spacesData.value = fetchedSpaces;
      log('Fetched Spaces: ${fetchedSpaces.spaces?.length ?? 0}');
    } catch (e) {
      error.value = 'Failed to fetch spaces: $e';
      Get.snackbar(
        'Error',
        error.value,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      log('Error fetching spaces: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
