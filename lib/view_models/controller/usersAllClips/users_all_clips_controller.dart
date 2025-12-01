import 'dart:developer';
import 'package:connectapp/models/AllUsersClips/all_user_clips_model.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../repository/UserSocialProfile/UserAllClips/user_all_clips_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class UsersAllClipsController extends GetxController {
  final _api = UserAllClipsRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final userClips = Rxn<AllUsersClipsModel>();
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setUserClips(AllUsersClipsModel? value) => userClips.value = value;

  @override
  void onInit() {
    super.onInit();
    fetchUserClips();
  }

  /// Shared function to load user clips
  Future<void> _loadUserClips({bool isRefresh = false}) async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      final userId = Get.arguments as String?;
      if (userId == null || userId.isEmpty) {
        setError("Invalid user ID.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      // log("${isRefresh ? "Refresh" : "Fetch"} TOKEN: ${loginData.token}, USER ID: $userId");

      final response = await _api.usersAllClips(loginData.token, userId);
      // log("${isRefresh ? "Refresh" : "Fetch"} API Response Parsed: ${response.toJson()}");

      setUserClips(response);
      setRxRequestStatus(Status.COMPLETED);
    } catch (err, stackTrace) {
      log("${isRefresh ? "Refresh" : "Fetch"} API Error: $err",
          stackTrace: stackTrace);
      setError(err.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }

  // First load
  Future<void> fetchUserClips() async {
    await _loadUserClips();
  }

  // Manual refresh
  Future<void> refreshUserClips() async {
    await _loadUserClips(isRefresh: true);
  }
}
