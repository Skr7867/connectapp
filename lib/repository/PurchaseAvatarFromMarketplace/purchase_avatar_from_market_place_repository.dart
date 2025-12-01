import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class PurchaseAvatarFromMarketPlaceRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> buyAvatar(
      String avatarId, Map<String, dynamic> data, String token) async {
    final url = "${ApiUrls.purchaseAvatarFromMarketPlaceApi}/$avatarId";

    return await _apiService.postApi(
      data,
      url,
      token: token,
    );
  }
}
