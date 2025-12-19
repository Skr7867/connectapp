import 'package:get/get.dart';

import '../../../data/response/status.dart';
import '../../../models/PendingFollowRequestModel/pending_follow_request_model.dart';
import '../../../repository/PendingFollowRequest/pending_follow_request_repository.dart';
import '../../../view_models/controller/userPreferences/user_preferences_screen.dart';

class PendingFollowRequestController extends GetxController {
  final _repository = PendingFollowRequestRepository();
  final UserPreferencesViewmodel _userPrefs = UserPreferencesViewmodel();

  // API State
  final rxStatus = Status.LOADING.obs;
  final pendingFollowRequest = PendingFollowRequestModel().obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingFollowRequests();
  }

  Future<void> fetchPendingFollowRequests() async {
    rxStatus.value = Status.LOADING;

    try {
      final String? token = await _userPrefs.getToken();

      if (token == null || token.isEmpty) {
        errorMessage.value = 'User not authenticated';
        rxStatus.value = Status.ERROR;
        return;
      }

      final response = await _repository.pendingFollowrequest(token);

      pendingFollowRequest.value = response;
      rxStatus.value = Status.COMPLETED;
    } catch (e) {
      errorMessage.value = e.toString();
      rxStatus.value = Status.ERROR;
    }
  }

  // Optional helper
  List<Requests> get requests => pendingFollowRequest.value.requests ?? [];
}
