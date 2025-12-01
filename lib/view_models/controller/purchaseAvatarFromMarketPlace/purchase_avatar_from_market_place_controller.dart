import 'package:get/get.dart';
import '../../../repository/PurchaseAvatarFromMarketplace/purchase_avatar_from_market_place_repository.dart';
import '../../../res/color/app_colors.dart';
import '../userPreferences/user_preferences_screen.dart';

class PurchaseAvatarFromMarketPlaceController extends GetxController {
  final _repository = PurchaseAvatarFromMarketPlaceRepository();
  final _prefs = UserPreferencesViewmodel();

  // Per-avatar loading state
  var loadingMap = <String, bool>{}.obs;

  var apiResponse = {}.obs;
  var errorMessage = "".obs;

  /// Buy Avatar Method
  Future<void> buyAvatar(String avatarId, Map<String, dynamic> data) async {
    try {
      loadingMap[avatarId] = true;
      loadingMap.refresh();
      errorMessage.value = "";

      final token = await _prefs.getToken();
      if (token == null) {
        errorMessage.value = "No token found. Please login again.";
        Get.snackbar(
          "Error",
          "No token found. Please login again.",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.redColor,
        );
        return;
      }

      final response = await _repository.buyAvatar(avatarId, data, token);
      apiResponse.value = response;

      if (response != null && response['message'] != null) {
        Get.snackbar(
          "Info",
          response['message'],
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.greenColor,
        );
      }
    } catch (error) {
      errorMessage.value = error.toString();
      Get.snackbar(
        "Error",
        error.toString(),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        backgroundColor: AppColors.redColor,
      );
    } finally {
      loadingMap[avatarId] = false;
      loadingMap.refresh();
    }
  }

  /// Helper to check if specific avatar is loading
  bool isLoading(String avatarId) {
    return loadingMap[avatarId] ?? false;
  }
}
