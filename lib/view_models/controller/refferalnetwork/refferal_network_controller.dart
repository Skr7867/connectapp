import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../models/ReffrealNetworkModel/refferals_network_model.dart';
import '../../../repository/RefferalNetwork/refferal_network_reposiotory.dart';
import '../userPreferences/user_preferences_screen.dart';

class RefferalNetworkController extends GetxController {
  final _api = RefferalNetworkReposiotory();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final userNetwork = ReferralsNetworkModel().obs;
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setUserList(ReferralsNetworkModel value) => userNetwork.value = value;

  @override
  void onInit() {
    super.onInit();
    userNetworkApi();
  }

  Future<void> userNetworkApi() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      // log("TOKEN: ${loginData.token}");

      final value = await _api.userRefferalNetwork(loginData.token);
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

      final value = await _api.userRefferalNetwork(loginData.token);
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
