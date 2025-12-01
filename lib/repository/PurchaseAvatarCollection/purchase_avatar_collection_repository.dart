import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class PurchaseAvatarCollectionRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> buyCollection(
      String collectionId, Map<String, dynamic> data, String token) async {
    final url = "${ApiUrls.purchaseAvatarCollectionApi}/$collectionId";

    return await _apiService.postApi(
      data,
      url,
      token: token,
    );
  }
}
