import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';

class TwoFaLoginRepository {
  final _apiServices = NetworkApiServices();

  Future<dynamic> twofauserLoginModel(Map<String, dynamic> data) async {
    return await _apiServices.postApi(data, ApiUrls.loginApi);
  }
}
