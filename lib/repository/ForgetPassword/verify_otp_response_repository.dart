import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';

class OtpVerificationRepository {
  final _apiServices = NetworkApiServices();

  Future<dynamic> verifyOtp(Map<String, dynamic> data) async {
    return await _apiServices.postApi(data, ApiUrls.verifyOtpApi);
  }
}
