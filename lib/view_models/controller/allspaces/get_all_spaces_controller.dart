import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../models/AllSpaces/get_all_spaces_model.dart';
import '../../../repository/AllSpaces/get_all_spaces_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class AllSpacesController extends GetxController {
  final _api = GetAllSpacesRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final spaces = <Spaces>[].obs;
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setSpaces(List<Spaces> value) => spaces.assignAll(value);

  @override
  void onInit() {
    super.onInit();
    fetchSpaces();
  }

  Future<void> fetchSpaces() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      // log("TOKEN: ${loginData.token}");

      final response = await _api.allSpaces(loginData.token);
      if (response.success == true) {
        // log("API Response: ${response.spaces!.map((space) => space.toJson()).toList()}");
        setRxRequestStatus(Status.COMPLETED);
        setSpaces(response.spaces ?? []);
      } else {
        setError("Failed to fetch spaces: Invalid response");
        setRxRequestStatus(Status.ERROR);
      }
    } catch (error) {
      // log("API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }

  Future<void> refreshSpaces() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      // log("Refresh TOKEN: ${loginData.token}");

      final response = await _api.allSpaces(loginData.token);
      if (response.success == true) {
        // log("Refresh API Response: ${response.spaces!.map((space) => space.toJson()).toList()}");
        setRxRequestStatus(Status.COMPLETED);
        setSpaces(response.spaces ?? []);
      } else {
        setError("Failed to refresh spaces: Invalid response");
        setRxRequestStatus(Status.ERROR);
      }
    } catch (error) {
      // log("Refresh API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }
}
