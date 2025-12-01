import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class CreateAvatarRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> createAvatar(Map<String, dynamic> data, String token) async {
    return await _apiService.postApi(data, ApiUrls.createAvatarApi,
        token: token);
  }
}
