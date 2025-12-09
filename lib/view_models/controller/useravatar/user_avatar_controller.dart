import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectapp/models/UserAvatar/user_avatar_model.dart';
import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';

import '../userPreferences/user_preferences_screen.dart';

class UserAvatarController extends GetxController {
  final _apiService = NetworkApiServices();
  final _dio = Dio();
  final userPreferences = UserPreferencesViewmodel();

  var purchasedAvatars = <PurchasedAvatars>[].obs;
  var currentAvatar = Rxn<CurrentAvatar>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserAvatars();
  }

  Future<void> fetchUserAvatars({bool isRefresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await userPreferences.getUser();
      final token = user?.token;
      final response =
          await _apiService.getApi(ApiUrls.userAvatarApi, token: token);
      final userAvatarModel = UserAvatarModel.fromJson(response);

      purchasedAvatars.value = userAvatarModel.purchasedAvatars ?? [];
      currentAvatar.value = userAvatarModel.currentAvatar;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCurrentAvatar(String newAvatarId) async {
    try {
      isUpdating.value = true;

      final user = await userPreferences.getUser();
      final token = user?.token;

      final response = await _dio.post(
        '${ApiUrls.baseUrl}/connect/v1/api/user/select-active-avatar',
        data: {'avatarId': newAvatarId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final selectedAvatar = purchasedAvatars.firstWhere(
          (avatar) => avatar.sId == newAvatarId,
          orElse: () => PurchasedAvatars(sId: newAvatarId),
        );
        currentAvatar.value = CurrentAvatar(
          sId: selectedAvatar.sId,
          name: selectedAvatar.name,
          imageUrl: selectedAvatar.imageUrl,
        );
        await fetchUserAvatars(isRefresh: true);
        // Get.snackbar(
        //   'Success',
        //   'Avatar changed successfully!',
        //   snackPosition: SnackPosition.TOP,
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to change avatar: ${response.statusMessage}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to change avatar';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Authentication failed. Please log in again.';
      } else {
        errorMessage = e.message ?? 'Failed to change avatar';
      }
      Get.snackbar(
        'Info',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return false;
    } catch (e) {
      Get.snackbar(
        'Info',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  bool isAvatarPurchased(String avatarId) {
    return purchasedAvatars.any((avatar) => avatar.sId == avatarId);
  }
}
