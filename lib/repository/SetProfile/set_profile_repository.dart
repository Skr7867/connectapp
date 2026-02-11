import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class SetProfileRepository {
  final _apiServices = NetworkApiServices();

  Future<dynamic> setProfileApi(String token, dynamic data) async {
    return await _apiServices.patchApi(
      data,
      ApiUrls.setProfileApi,
      token: token,
    );
  }
}
