import 'dart:developer';
import 'package:connectapp/models/CREATORPANEL/Profile/creators_profile_model.dart';
import 'package:connectapp/repository/CREATORPANEL/CreatorProfile/creator_profile_repository.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../controller/userPreferences/user_preferences_screen.dart';

class CreatorProfileController extends GetxController {
  final _api = CreatorProfileRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final creatorList = CreatorProfileModel().obs;
  final error = ''.obs;

  void setError(String value) {
    error.value = value;
    log('Error set: $value');
  }

  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setUserList(CreatorProfileModel value) {
    creatorList.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    creatorListApi();
  }

  Future<void> creatorListApi() async {
    setRxRequestStatus(Status.LOADING);
    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }
      log("TOKEN: ${loginData.token}");
      final value = await _api.creatorProfile(loginData.token.toString());
      log("API Response: $value");
      setUserList(value);
      setRxRequestStatus(Status.COMPLETED);
    } catch (e, stackTrace) {
      log("API Error: $e", stackTrace: stackTrace);
      setError(e.toString());
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
      log("Refresh TOKEN: ${loginData.token}");
      final value = await _api.creatorProfile(loginData.token);
      log("Refresh API Response: ${value.toJson()}");
      setUserList(value);
      setRxRequestStatus(Status.COMPLETED);
    } catch (e, stackTrace) {
      log("Refresh API Error: $e", stackTrace: stackTrace);
      setError(e.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }
}
