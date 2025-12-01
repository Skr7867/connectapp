import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../res/routes/routes_name.dart';
import '../profile/user_profile_controller.dart';
import '../useravatar/user_avatar_controller.dart';

class PurchaseAvatarController extends GetxController {
  final Dio _dio = Dio();
  final userCoins = Get.find<UserProfileController>();
  final userAvatarController = Get.find<UserAvatarController>();
  var purchasingAvatars = <String, bool>{}.obs;

  Future<bool> purchaseAvatar(String avatarId, int requiredCoins, String? token,
      {bool isPurchased = false}) async {
    try {
      if (isPurchased) {
        Get.snackbar(
          'Info',
          'Avatar already purchased!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return true;
      }

      if (token == null || token.isEmpty) {
        Get.snackbar(
          'Error',
          'You are not logged in. Please log in to purchase avatars.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      if (requiredCoins > 0 &&
          userCoins.userList.value.wallet!.coins! < requiredCoins) {
        Get.snackbar(
          'Insufficient Coins',
          'You need ${requiredCoins - userCoins.userList.value.wallet!.coins!.toInt()} coins to buy this avatar',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }

      purchasingAvatars[avatarId] = true;
      update();

      final response = await _dio.post(
        '${ApiUrls.baseUrl}/connect/v1/api/user/buy-avatar/$avatarId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        userCoins.userList();
        await userAvatarController.fetchUserAvatars(isRefresh: true);

        if (requiredCoins == 0) {
          await userAvatarController.updateCurrentAvatar(avatarId);
        }

        Get.snackbar(
          'Success',
          requiredCoins == 0
              ? 'Free avatar acquired!'
              : 'Avatar purchased successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to purchase avatar: ${response.statusMessage}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } on DioException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Authentication failed. Please log in again.';
        Get.offAllNamed(RouteName.loginScreen);
      } else {
        errorMessage = e.message ?? 'Failed to purchase avatar';
      }
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // log('Error occurred', error: e);
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // log('Error occurred', error: e);
      return false;
    } finally {
      purchasingAvatars[avatarId] = false;
      update();
    }
  }

  bool isAvatarPurchasing(String avatarId) {
    return purchasingAvatars[avatarId] ?? false;
  }
}
