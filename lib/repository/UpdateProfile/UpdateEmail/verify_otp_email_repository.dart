import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';

class VerifyOtpEmailRepository {
  final _apiServices = NetworkApiServices();

  Future<dynamic> verifyOtpEmail(Map<String, dynamic> data,
      {String? token}) async {
    return await _apiServices.postApi(data, ApiUrls.verifyOTPEmail,
        token: token);
  }
}
