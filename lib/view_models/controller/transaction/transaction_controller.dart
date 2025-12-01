import 'package:connectapp/models/Transaction/transaction_model.dart';
import 'package:connectapp/repository/TransactionHistory/transaction_repository.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../userPreferences/user_preferences_screen.dart';

class UserTransactionController extends GetxController {
  final _api = TransactionRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final userTransaction = UserTransactionModel().obs;
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setUserTransaction(UserTransactionModel value) =>
      userTransaction.value = value;

  @override
  void onInit() {
    super.onInit();
    userTransactionApi();
  }

  Future<void> userTransactionApi() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      final value = await _api.userTransaction(loginData.token);

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

      final value = await _api.userTransaction(loginData.token);

      setRxRequestStatus(Status.COMPLETED);
      setUserTransaction(value);
    } catch (error) {
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }
}
