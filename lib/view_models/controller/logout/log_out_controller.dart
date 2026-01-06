import 'dart:developer';
import 'package:get/get.dart';
import '../../../repository/Logout/logout_repository.dart';
import '../navbar/bottom_bav_bar_controller.dart';
import '../userPreferences/user_preferences_screen.dart';
// Import chat-related controllers
import '../../../view_models/controller/unreadCount/unread_count_controller.dart';
import '../../../view_models/controller/groupUnreadCount/group_unread_count_controller.dart';

class LogoutController extends GetxController {
  final LogoutRepository _repository = LogoutRepository();
  final UserPreferencesViewmodel _userPref = UserPreferencesViewmodel();

  RxBool loading = false.obs;

  Future<bool> logout() async {
    loading.value = true;

    try {
      final token = await _userPref.getToken();
      if (token == null) {
        await _userPref.clearAll();
        await _clearAllControllers();
        return true;
      }

      log("🔑 Logging out with token: $token");
      await _repository.logoutUser(token);
      await _userPref.clearAll();
      await _clearAllControllers();
      return true;
    } catch (e) {
      log("❌ Logout error: $e");
      return false;
    } finally {
      loading.value = false;
    }
  }

  // Add this method to clear all user-related controllers
  Future<void> _clearAllControllers() async {
    try {
      // Delete UnreadCount controller
      if (Get.isRegistered<UnreadCountController>()) {
        Get.delete<UnreadCountController>(force: true);
        log("✅ UnreadCountController deleted");
      }

      // Delete GroupUnreadCount controller
      if (Get.isRegistered<GroupUnreadCountController>()) {
        Get.delete<GroupUnreadCountController>(force: true);
        log("✅ GroupUnreadCountController deleted");
      }

      // Delete NavbarController to reset navigation
      if (Get.isRegistered<NavbarController>()) {
        Get.delete<NavbarController>(force: true);
        log("✅ NavbarController deleted");
      }

      // Force garbage collection
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      log("⚠️ Error clearing controllers: $e");
    }
  }
}
