import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../models/GetClipByid/get_clip_by_id_model.dart';
import '../../../repository/GetClipByid/get_clip_by_id_repository.dart';

class GetClipByIdController extends GetxController {
  final _api = GetClipByIdRepository();
  final userPreferences = UserPreferencesViewmodel();

  // Rx variables
  var rxRequestStatus = Status.LOADING.obs;
  var clipData = Rxn<Clip>();
  var error = ''.obs;

  /// Fetch clip details by ID
  Future<void> fetchClipById(String clipId) async {
    rxRequestStatus.value = Status.LOADING;
    try {
      final token = await userPreferences.getToken();
      // log(" Using token: $token");
      // log(" Fetching clip with ID: $clipId");

      final clipResponse = await _api.getClipByid(token!, clipId);

      if (clipResponse.clip != null) {
        clipData.value = clipResponse.clip;
        rxRequestStatus.value = Status.COMPLETED;
        // log(" Clip fetched successfully: ${clipData.value?.sId}");
      } else {
        error.value = "Clip not found";
        rxRequestStatus.value = Status.ERROR;
      }
    } catch (e) {
      error.value = e.toString();
      rxRequestStatus.value = Status.ERROR;
      // log(" Error while fetching clip by ID: $e");
    }
  }
}
