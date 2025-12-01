import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class DeleteAvatarRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> deleteAvatar(String avatarId, String token) async {
    final url = "${ApiUrls.deleteAvatarApi}/$avatarId";
    return await _apiService.deleteApi(url, token: token);
  }
}
