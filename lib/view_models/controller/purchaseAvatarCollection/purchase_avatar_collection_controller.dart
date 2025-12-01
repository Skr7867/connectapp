import 'package:connectapp/repository/PurchaseAvatarCollection/purchase_avatar_collection_repository.dart';
import 'package:get/get.dart';
import '../../../res/color/app_colors.dart';
import '../userPreferences/user_preferences_screen.dart';

class PurchaseAvatarCollectionController extends GetxController {
  final _repository = PurchaseAvatarCollectionRepository();
  final _prefs = UserPreferencesViewmodel();

  // Per-avatar loading state
  var loadingMap = <String, bool>{}.obs;

  var apiResponse = {}.obs;
  var errorMessage = "".obs;

  // Buy Avatar Method
  Future<void> buyCollection(
      String collectionId, Map<String, dynamic> data) async {
    try {
      loadingMap[collectionId] = true;
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

      final response =
          await _repository.buyCollection(collectionId, data, token);
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
      loadingMap[collectionId] = false;
      loadingMap.refresh();
    }
  }

  /// Helper to check if specific avatar is loading
  bool isLoading(String collectionId) {
    return loadingMap[collectionId] ?? false;
  }
}
