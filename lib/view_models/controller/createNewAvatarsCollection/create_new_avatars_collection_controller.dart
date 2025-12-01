import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../repository/createAvatarCollection/create_avatar_collection_repository.dart';
import '../../../res/routes/routes_name.dart';
import '../userPreferences/user_preferences_screen.dart';

class CreateNewAvatarsCollectionController extends GetxController {
  // Text Controllers
  final avatarsCollectionName = TextEditingController().obs;
  final avatarsDescriptionName = TextEditingController().obs;
  final collectionPrice = TextEditingController().obs;
  final RxBool isTermsAccepted = false.obs;
  final RxBool isLoading = false.obs;
  var errorMessage = ''.obs;

  final _repository = CreateAvatarCollectionRepository();
  final _prefs = UserPreferencesViewmodel();

  final RxList<String> selectedAvatarIds = <String>[].obs;

  /// Create Collection API Call
  Future<void> createCollection() async {
    // Validate inputs
    if (avatarsCollectionName.value.text.trim().isEmpty) {
      Utils.snackBar('Please fill up the collection name', 'Info');
      return;
    }

    if (selectedAvatarIds.isEmpty) {
      Utils.snackBar('Please select at least one Avatar', 'Info');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get token
      final token = await _prefs.getToken();

      if (token == null) {
        errorMessage.value = 'User not logged in';
        Utils.snackBar('Please log in again', 'Error');
        Get.offAllNamed(RouteName.loginScreen);
        return;
      }

      // Payload
      final payload = {
        "name": avatarsCollectionName.value.text.trim(),
        "description": avatarsDescriptionName.value.text.trim(),
        "coins": int.tryParse(collectionPrice.value.text.trim()) ?? 0,
        "isPublished": isTermsAccepted.value,
        "avatarIds": selectedAvatarIds.toList(),
      };

      // Pass token into repository
      final response = await _repository.createAvatarsCollection(
        payload,
        token,
      );

      // Handle API Response
      if (response != null && response['success'] == true) {
        Utils.snackBar('Collection created successfully', 'Success');
        // Optionally, clear form or navigate
        avatarsCollectionName.value.clear();
        avatarsDescriptionName.value.clear();
        collectionPrice.value.clear();
        selectedAvatarIds.clear();
        isTermsAccepted.value = false;
      } else {
        errorMessage.value =
            response?['message'] ?? 'Failed to create collection';
        if (response?['statusCode'] == 401 ||
            response?['message']
                    ?.toString()
                    .toLowerCase()
                    .contains('expired') ==
                true) {
          Utils.snackBar('Session expired. Please log in again', 'Error');
          await _prefs.removeUser();
          Get.offAllNamed(RouteName.loginScreen);
        } else {
          Utils.snackBar(errorMessage.value, 'Info');
        }
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      // developer.log('Create collection error: $e');
      Utils.snackBar('$e', 'Info');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    avatarsCollectionName.value.dispose();
    avatarsDescriptionName.value.dispose();
    collectionPrice.value.dispose();
    super.onClose();
  }
}
