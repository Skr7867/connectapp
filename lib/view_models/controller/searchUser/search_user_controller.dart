import 'dart:developer';

import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../models/AllUsers/search_users_model.dart';
import '../../../repository/SearchUser/search_user_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class SearchUsersController extends GetxController {
  final _api = SearchUserRepository();
  final _prefs = UserPreferencesViewmodel();
  final isLoading = false.obs;

  final rxRequestStatus = Status.COMPLETED.obs;
  final users = <SearchedUser>[].obs;
  final error = ''.obs;

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      users.clear();
      return;
    }

    isLoading.value = true;
    rxRequestStatus.value = Status.LOADING;

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        error.value = "User not authenticated. Token not found.";
        rxRequestStatus.value = Status.ERROR;
        isLoading.value = false;
        return;
      }

      final response = await _api.searchUsers(loginData.token, query);
      log("Search Response: ${response.searchedUser?.map((u) => u.toJson()).toList()}");

      users.assignAll(response.searchedUser ?? []);
      rxRequestStatus.value = Status.COMPLETED;
    } catch (e) {
      log("Search API Error: $e");
      error.value = e.toString();
      rxRequestStatus.value = Status.ERROR;
    } finally {
      isLoading.value = false;
    }
  }
}
