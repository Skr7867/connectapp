import 'dart:convert';
import 'dart:developer';

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
  bool get hasRealData {
    return rxRequestStatus.value == Status.COMPLETED &&
        userList.value.fullName != null &&
        userList.value.fullName!.isNotEmpty;
  }

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

  // Load cached data if available - but DON'T set status to COMPLETED
  void _loadCachedData() {
    final cachedData = _storage.read(_cacheKey);
    if (cachedData != null) {
      try {
        final Map<String, dynamic> jsonData = jsonDecode(cachedData);
        userList.value = UserProfileModel.fromJson(jsonData);
        // Don't set status to COMPLETED here - let API call do that
        log('Loaded cached user profile');
      } catch (e) {
        // Cache is corrupted, ignore and fetch fresh data
        log('Cache load error: $e');
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadCachedData();
  }

  Future<void> userListApi({bool forceRefresh = false}) async {
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

  void clearUserData() {
    userList.value = UserProfileModel();
    userMediaList.clear();
    rxRequestStatus.value = Status.LOADING;
    error.value = '';
    // Also clear cache
    _storage.remove(_cacheKey);
  }
}
