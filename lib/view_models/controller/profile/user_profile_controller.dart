import 'dart:convert';
import 'package:connectapp/models/userProfile/user_profile_model.dart';
import 'package:connectapp/repository/UserProfile/user_profile_repository.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/response/status.dart';
import '../../../models/UserProfile/user_profile_media_list_model.dart';
import '../userPreferences/user_preferences_screen.dart';

class UserProfileController extends GetxController {
  final _api = GetUserProfileRepository();
  final _prefs = UserPreferencesViewmodel();
  final _storage = GetStorage();

  final rxRequestStatus = Status.LOADING.obs;
  final userList = UserProfileModel().obs;
  final userMediaList = <Media>[].obs;
  final error = ''.obs;

  final String _cacheKey = 'cached_user_profile';

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;

  void setUserList(UserProfileModel value, {bool saveLocal = true}) {
    userList.value = value;
    if (saveLocal) {
      _storage.write(_cacheKey, jsonEncode(value.toJson()));
    }
  }

  void setUserMediaList(UserProfileMediaListModel value) {
    userMediaList.value = value.media;
  }

  @override
  void onInit() {
    super.onInit();
    _loadCachedData();
    userListApi(firstLoad: true);
  }

  /// Load data from local storage
  void _loadCachedData() {
    final cachedData = _storage.read(_cacheKey);
    if (cachedData != null) {
      try {
        final decoded = jsonDecode(cachedData);
        final cachedUser = UserProfileModel.fromJson(decoded);
        setUserList(cachedUser, saveLocal: false);
        setRxRequestStatus(Status.COMPLETED);
      } catch (e) {
        print(" Failed to load cached user data: $e");
      }
    }
  }

  Future<void> userListApi({bool firstLoad = false}) async {
    if (!firstLoad && userList.value.fullName != null) return;

    setRxRequestStatus(Status.LOADING);
    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      final value = await _api.userProfileData(loginData.token);
      setUserList(value, saveLocal: true);
      setRxRequestStatus(Status.COMPLETED);
    } catch (e) {
      setError(e.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }

  Future<void> mediaListApi(String chatType, String userId) async {
    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      setRxRequestStatus(Status.LOADING);

      final value = await _api.userMediaListData(
        loginData.token,
        chatType,
        userId,
      );

      setUserMediaList(value);
      setRxRequestStatus(Status.COMPLETED);
    } catch (e) {
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

      final value = await _api.userProfileData(loginData.token);
      setUserList(value, saveLocal: true);
      setRxRequestStatus(Status.COMPLETED);
    } catch (e) {
      setError(e.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }
}
