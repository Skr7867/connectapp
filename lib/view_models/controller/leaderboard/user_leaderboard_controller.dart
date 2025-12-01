import 'package:connectapp/models/Leaderboard/leaderboard_response_model.dart';
import 'package:connectapp/repository/Leaderboard/leaderboard_repository.dart';
import 'package:get/get.dart';

import '../../../data/response/status.dart';
import '../userPreferences/user_preferences_screen.dart';

class UserLeaderboardController extends GetxController {
  final _api = LeaderboardRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final userLeaderboard = LeaderboardResponseModel().obs;
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setUserList(LeaderboardResponseModel value) =>
      userLeaderboard.value = value;

  @override
  void onInit() {
    super.onInit();
    userListApi();
  }

  Future<void> userListApi() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      // log("TOKEN: ${loginData.token}");

      final value = await _api.userLeaderboard(loginData.token);
      // log("API Response: ${value.toJson()}");
      setRxRequestStatus(Status.COMPLETED);
      setUserList(value);
    } catch (error) {
      // log("API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }

  Future<void> refreshApi() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      // log("Refresh TOKEN: ${loginData.token}");

      final value = await _api.userLeaderboard(loginData.token);
      // log("API Response: ${value.toJson()}");
      setRxRequestStatus(Status.COMPLETED);
      setUserList(value);
    } catch (error) {
      // log("Refresh API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }
}
