import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';
import '../../view_models/controller/userPreferences/user_preferences_screen.dart';

class UpdateAvatarRepository {
  final _apiService = NetworkApiServices();
  final _prefs = UserPreferencesViewmodel();

  Future<dynamic> updateAvatar(
      String avatarId, Map<String, dynamic> data) async {
    final token = await _prefs.getToken();

    return await _apiService.patchApi(
      data,
      "${ApiUrls.updateAvatarApi}/$avatarId",
      token: token,
    );
  }
}
