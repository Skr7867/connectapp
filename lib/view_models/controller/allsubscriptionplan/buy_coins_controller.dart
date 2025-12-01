import 'package:connectapp/data/response/status.dart';
import 'package:connectapp/models/AllSubscriptionPlan/buy_coins_model.dart';
import 'package:connectapp/repository/AllSubscriptionPlans/buy_coins_repository.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../res/routes/routes_name.dart';
import '../userPreferences/user_preferences_screen.dart';

class BuyCoinsController extends GetxController {
  final _api = BuyCoinsRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final coinsPackages = BuyCoinsModel().obs;
  final error = ''.obs;
  bool isLoading = false;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setCoinsPackages(BuyCoinsModel value) => coinsPackages.value = value;

  @override
  void onInit() {
    super.onInit();
    fetchCoinsPackages();
  }

  Future<void> fetchCoinsPackages() async {
    setRxRequestStatus(Status.LOADING);
    try {
      final loginData = await _prefs.getUser();
      // log('Fetched user data: $loginData', name: 'BuyCoinsController');
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        Get.snackbar(
          'Authentication Error',
          'User not authenticated. Please log in.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 4),
          margin: EdgeInsets.all(10),
        );
        await Future.delayed(Duration(seconds: 4));
        Get.offNamed('/login');
        return;
      }

      // log("TOKEN: ${loginData.token}", name: 'BuyCoinsController');

      final response = await _api.coinsPackage(loginData.token);
      if (response.packages == null || response.packages!.isEmpty) {
        setError("Invalid API response: No coin packages found.");
        setRxRequestStatus(Status.ERROR);
        Get.snackbar(
          'Error',
          'No coin packages available.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 4),
          margin: EdgeInsets.all(10),
        );
        return;
      }
      // log("API Response: ${response.toJson()}", name: 'BuyCoinsController');
      setRxRequestStatus(Status.COMPLETED);
      setCoinsPackages(response);
    } catch (error) {
      // log("API Error: $error",
      //     stackTrace: stackTrace, name: 'BuyCoinsController');
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
      Get.snackbar(
        'Error',
        error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
        margin: EdgeInsets.all(10),
      );
    }
  }

  Future<void> refreshCoinsPackages() async {
    setRxRequestStatus(Status.LOADING);
    try {
      final loginData = await _prefs.getUser();
      // log('Fetched user data (refresh): $loginData',
      //     name: 'BuyCoinsController');
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        Get.snackbar(
          'Authentication Error',
          'User not authenticated. Please log in.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 4),
          margin: EdgeInsets.all(10),
        );
        await Future.delayed(Duration(seconds: 4));
        Get.offAllNamed(RouteName.loginScreen);
        return;
      }

      // log("Refresh TOKEN: ${loginData.token}", name: 'BuyCoinsController');

      final response = await _api.coinsPackage(loginData.token);
      if (response.packages == null || response.packages!.isEmpty) {
        setError("Invalid API response: No coin packages found.");
        setRxRequestStatus(Status.ERROR);
        Get.snackbar(
          'Error',
          'No coin packages available.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 4),
          margin: EdgeInsets.all(10),
        );
        return;
      }
      // log("API Response: ${response.toJson()}", name: 'BuyCoinsController');
      setRxRequestStatus(Status.COMPLETED);
      setCoinsPackages(response);
    } catch (error) {
      // log("Refresh API Error: $error",
      //     stackTrace: stackTrace, name: 'BuyCoinsController');
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
      Get.snackbar(
        'Error',
        error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
        margin: EdgeInsets.all(10),
      );
    }
  }
}
