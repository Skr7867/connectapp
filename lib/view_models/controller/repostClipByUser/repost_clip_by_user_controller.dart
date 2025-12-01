import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../../../models/ClipRepostByUser/clip_repost_by_user_model.dart';
import '../../../repository/ClipRepostByUser/clip_repost_by_user_repository.dart';
import '../userPreferences/user_preferences_screen.dart';
import '../../../models/UserLogin/user_login_model.dart';

class ClipRepostByUserController extends GetxController {
  final ClipRepostByUserRepository _repository = ClipRepostByUserRepository();
  final rxRequestStatus = Status.LOADING.obs;
  final repostedClips = Rxn<ClipRepostByUser>();
  final error = ''.obs;

  Future<void> fetchRepostedClips(String userId) async {
    if (userId.isEmpty) {
      error.value = 'Invalid user ID';
      rxRequestStatus.value = Status.ERROR;
      return;
    }

    rxRequestStatus.value = Status.LOADING;

    try {
      final UserPreferencesViewmodel userPreferences =
          UserPreferencesViewmodel();
      LoginResponseModel? userData = await userPreferences.getUser();
      final token = userData!.token;

      final response = await _repository.clipRepostByUser(token, userId);
      repostedClips.value = response;
      rxRequestStatus.value = Status.COMPLETED;
    } catch (e) {
      error.value = 'Error fetching reposted clips: $e';
      rxRequestStatus.value = Status.ERROR;
    }
  }

  Future<void> refreshRepostedClips(String userId) async {
    await fetchRepostedClips(userId);
  }
}
