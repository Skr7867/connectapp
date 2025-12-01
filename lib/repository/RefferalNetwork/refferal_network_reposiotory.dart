import '../../data/network/network_api_services.dart';
import '../../models/ReffrealNetworkModel/refferals_network_model.dart';
import '../../res/api_urls/api_urls.dart';

class RefferalNetworkReposiotory {
  final _apiService = NetworkApiServices();

  Future<ReferralsNetworkModel> userRefferalNetwork(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.refferalNetworkApi, token: token);
    return ReferralsNetworkModel.fromJson(response);
  }
}
