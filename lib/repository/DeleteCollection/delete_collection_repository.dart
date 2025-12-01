import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class DeleteCollectionRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> deleteCollection(String collectionId, String token) async {
    final url = "${ApiUrls.deleteAvatarsCollectionApi}/$collectionId";
    return await _apiService.deleteApi(url, token: token);
  }
}
