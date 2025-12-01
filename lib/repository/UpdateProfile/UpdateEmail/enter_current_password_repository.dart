// import 'package:connectapp/data/network/network_api_services.dart';
// import 'package:connectapp/res/api_urls/api_urls.dart';

// class EnterCurrentPasswordRepository {
//   final _apiServices = NetworkApiServices();

//   Future<dynamic> enterCurrentPassword(Map<String, dynamic> data) async {
//     return await _apiServices.postApi(data, ApiUrls.verifyUpdateEmailPassword);
//   }
// }

import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';

class EnterCurrentPasswordRepository {
  final _apiServices = NetworkApiServices();

  Future<dynamic> enterCurrentPassword(Map<String, dynamic> data,
      {String? token}) async {
    return await _apiServices.postApi(data, ApiUrls.verifyUpdateEmailPassword,
        token: token);
  }
}
