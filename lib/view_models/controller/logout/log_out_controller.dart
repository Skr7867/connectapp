import 'dart:developer';
import 'package:get/get.dart';
import '../../../repository/Logout/logout_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

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
        return true;
      }

      log("🔑 Logging out with token: $token");
      await _repository.logoutUser(token);
      await _userPref.clearAll();
      return true;
    } catch (e) {
      log("❌ Logout error: $e");
      return false;
    } finally {
      loading.value = false;
    }
  }
}
