import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';

class UserRegistrationRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> registerRequestModel(Map<String, dynamic> data) async {
    return await _apiService.postApi(data, ApiUrls.signupApi);
  }
}
