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

  @override
  void onInit() {
    super.onInit();
    syncPurchasedPlans();
  }

  Future<void> syncPurchasedPlans() async {
    try {
      userCoinsController.userList(); // Refresh user data
      final user = userCoinsController.userList.value;
      if (user.subscription?.planId != null) {
        final activePlanId = user.subscription!.planId;
        if (!purchasedPlans.contains(activePlanId)) {
          purchasedPlans.add(activePlanId!);
          // log('Synced active plan: $activePlanId');
        }
      }
    } catch (e) {
      // log('Error syncing purchased plans: $e');
    }
  }

  Future<void> processPayment(String planId, int coinsRequired,
      {bool isPremiumPlus = false}) async {
    final user = userCoinsController.userList.value;
    if (isPremiumPlus && user.subscription!.status == 'Active') {
      Utils.snackBar(
        "Active Subscription",
        "You already have an active subscription.",
      );
      return;
    }

    final int userCoins = user.wallet!.coins!;
    if (userCoins < coinsRequired) {
      Utils.snackBar(
        "You need at least $coinsRequired coins to purchase this plan.",
        "Insufficient Coins",
      );
      return;
    }

    try {
      isPaying[planId] = true;
      final userPrefs = await _userPrefs.getUser();
      if (userPrefs == null) {
        Utils.snackBar(
          "Authentication Error",
          "No user token found. Please log in again.",
        );
        return;
      }

      // log('Attempting to purchase plan: $planId with token: ${userPrefs.token}');
      final response = await http.post(
        Uri.parse(
            '${ApiUrls.baseUrl}/connect/v1/api/user/purchase-subscription/$planId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userPrefs.token}',
        },
        body: jsonEncode({'planId': planId}),
      );

      // log('Response status: ${response.statusCode}');
      // log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true || responseData['status'] == 200) {
          Utils.snackBar(
            "Plan purchased successfully.",
            "Success",
          );
          purchasedPlans.add(planId);
          userCoinsController.userList();
          // log('Plan $planId purchased successfully');
        } else {
          Utils.snackBar(
            "Error",
            responseData['message'] ?? "Failed to purchase plan.",
          );
          // log('Purchase failed: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        final responseData = jsonDecode(response.body);
        Utils.snackBar(
          "Error",
          responseData['message'] ??
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
