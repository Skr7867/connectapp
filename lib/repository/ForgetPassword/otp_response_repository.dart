import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';

class OtpResponseRepository {
  final _apiServices = NetworkApiServices();

  Future<dynamic> otpResponse(Map<String, dynamic> data) async {
    return await _apiServices.postApi(data, ApiUrls.sendOtpApi);
  }
}
