import '../../../data/network/network_api_services.dart';
import '../../../res/api_urls/api_urls.dart';

class CreateSpaceRepository {
  final _apiServices = NetworkApiServices();

  Future<dynamic> createSpace(Map<String, dynamic> data,
      {String? token}) async {
    return await _apiServices.postApi(data, ApiUrls.createSpaceApi,
        token: token);
  }
}
