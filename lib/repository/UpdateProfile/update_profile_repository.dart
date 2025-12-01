import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class UpdateProfileRepository {
  final _apiServices = NetworkApiServices();

  Future<dynamic> updateProfile(Map<String, dynamic> data, String token) async {
    try {
      return await _apiServices.patchApi(
        data,
        ApiUrls.updateProfileAPi,
        token: token,
      );
    } catch (e) {
      rethrow;
    }
  }
}
