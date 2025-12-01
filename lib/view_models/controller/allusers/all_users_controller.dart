import 'dart:developer';

import 'package:get/get.dart';

import '../../../data/response/status.dart';
import '../../../models/AllUsers/show_all_users_model.dart';
import '../../../repository/AllUsers/all_users_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class AllUsersController extends GetxController {
  final _api = AllUsersRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final users = <Users>[].obs;
  final allUsers = <Users>[].obs;
  final error = ''.obs;
  final searchQuery = ''.obs;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setUsers(List<Users> value) {
    allUsers.assignAll(value);
    users.assignAll(value);
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    filterUsers();
  }

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      // log("TOKEN: ${loginData.token}");

      final response = await _api.allUsers(loginData.token);
      log("API Response: ${response.users?.map((user) => user.toJson()).toList()}");
      setRxRequestStatus(Status.COMPLETED);
      setUsers(response.users ?? []);
    } catch (error, stackTrace) {
      log("API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }

  Future<void> refreshUsers() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      log("Refresh TOKEN: ${loginData.token}");

      final response = await _api.allUsers(loginData.token);
      log("Refresh API Response: ${response.users?.map((user) => user.toJson()).toList()}");
      setRxRequestStatus(Status.COMPLETED);
      setUsers(response.users ?? []);
    } catch (error, stackTrace) {
      log("Refresh API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }

  void filterUsers() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      users.assignAll(allUsers);
    } else {
      users.assignAll(allUsers.where((user) {
        return (user.fullName?.toLowerCase().contains(query) ?? false) ||
            (user.username?.toLowerCase().contains(query) ?? false) ||
            (user.email?.toLowerCase().contains(query) ?? false);
      }).toList());
    }
  }
}
