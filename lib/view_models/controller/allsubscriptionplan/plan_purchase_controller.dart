import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../res/api_urls/api_urls.dart';
import '../../../utils/utils.dart';
import '../profile/user_profile_controller.dart';
import '../userPreferences/user_preferences_screen.dart';

class PlanPurchaseController extends GetxController {
  final UserPreferencesViewmodel _userPrefs = UserPreferencesViewmodel();
  RxMap<String, bool> isPaying = <String, bool>{}.obs;
  RxList<String> purchasedPlans = <String>[].obs;

  final userCoinsController = Get.find<UserProfileController>();

  Future<void> processPayment(String planId, int coinsRequired,
      {required bool isPremiumPlus}) async {
    final int userCoins = userCoinsController.userList.value.wallet!.coins!;

    if (userCoins < coinsRequired) {
      Utils.snackBar(
        "You need at least $coinsRequired coins to purchase this plan.",
        "Insufficient Coins",
      );
      return;
    }

    try {
      isPaying[planId] = true;

      // Fetch the user data to get the token
      final user = await _userPrefs.getUser();
      if (user == null) {
        Utils.snackBar(
          "Authentication Error",
          "No user token found. Please log in again.",
        );
        return;
      }
      // log('Attempting to purchase plan: $planId with token: ${user.token}');
      final response = await http.post(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/user/purchase-subscription/$planId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode({'planId': planId}),
      );

      // log('Response status: ${response.statusCode}');
      // log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true || responseData['status'] == 200) {
          Utils.snackBar(
            "Success",
            "Plan purchased successfully.",
          );
          purchasedPlans.add(planId);
          userCoinsController.userList();
          // log('Plan $planId purchased successfully');
        } else {
          Utils.snackBar(
            responseData['message'] ?? "Failed to purchase plan.",
            "Error",
          );
          // log('Purchase failed: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        Utils.snackBar(
          "Error",
          "Failed to purchase plan: ${response.reasonPhrase}",
        );
        // log('Purchase failed with status ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      Utils.snackBar(
        "Failed to purchase plan: $e",
        "Error",
      );
      // log('Error purchasing plan $planId: $e');
    } finally {
      isPaying[planId] = false;
    }
  }
}
