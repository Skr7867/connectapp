import 'dart:developer';
import 'package:connectapp/repository/TransactionHistory/coins_transaction_repository.dart';
import 'package:get/get.dart';

import '../../../data/response/status.dart';
import '../../../models/Transaction/user_coins_transaction_model.dart';
import '../userPreferences/user_preferences_screen.dart';

class UserCoinsTransactionController extends GetxController {
  final _api = CoinsTransactionRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final usercoinsTransaction = UserCoinsTransactionModel().obs;
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setUserTransaction(UserCoinsTransactionModel value) =>
      usercoinsTransaction.value = value;

  @override
  void onInit() {
    super.onInit();
    userCoinsTransactionApi();
  }

  Future<void> userCoinsTransactionApi() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      final value = await _api.userCoinsTransaction(loginData.token);

      setRxRequestStatus(Status.COMPLETED);
      setUserTransaction(value);
    } catch (error) {
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

      final value = await _api.userCoinsTransaction(loginData.token);
      log("API Response: ${value.toJson()}");
      setRxRequestStatus(Status.COMPLETED);
      setUserTransaction(value);
    } catch (error) {
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }
}
