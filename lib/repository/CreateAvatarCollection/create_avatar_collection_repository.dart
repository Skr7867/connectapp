import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class CreateAvatarCollectionRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> createAvatarsCollection(
    Map<String, dynamic> data,
    String token,
  ) async {
    final url = ApiUrls.createNewAvatarsCollectionApi;

    return await _apiService.postApi(
      data,
      url,
      token: token,
    );
  }
}
