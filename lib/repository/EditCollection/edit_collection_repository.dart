import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';
import '../../view_models/controller/userPreferences/user_preferences_screen.dart';

class EditCollectionRepository {
  final _apiService = NetworkApiServices();
  final _prefs = UserPreferencesViewmodel();

  Future<dynamic> editCollection(
      String collectionId, Map<String, dynamic> data) async {
    final token = await _prefs.getToken();

    return await _apiService.patchApi(
      data,
      "${ApiUrls.editAvatarsCollectionApi}/$collectionId",
      token: token,
    );
  }
}
