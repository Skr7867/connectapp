import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';

class ValidateEmailRepository {
  final _apiServices = NetworkApiServices();

  Future<dynamic> validateEmail(Map<String, dynamic> data,
      {String? token}) async {
    return await _apiServices.postApi(data, ApiUrls.validateNewEmail,
        token: token);
  }
}
