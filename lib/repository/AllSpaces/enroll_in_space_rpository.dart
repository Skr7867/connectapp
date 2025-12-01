import 'package:connectapp/data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class EnrollSpaceRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> enrollSpace(String spaceId, String token) async {
    final url = "${ApiUrls.enrollSpaceApi}/$spaceId";

    final response = await _apiService.postApi(null, url, token: token);
    return response;
  }
}
