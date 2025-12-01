import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';

class ResetPasswordRepository {
  final _apiServices = NetworkApiServices();

  Future<dynamic> resetPassword(Map<String, dynamic> data) async {
    return await _apiServices.patchApi(data, ApiUrls.resetPasswordApi);
  }
}
