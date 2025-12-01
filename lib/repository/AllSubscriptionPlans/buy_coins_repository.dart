import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/AllSubscriptionPlan/buy_coins_model.dart';

import '../../res/api_urls/api_urls.dart';

class BuyCoinsRepository {
  final _apiService = NetworkApiServices();

  Future<BuyCoinsModel> coinsPackage(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.buyCoinsApi, token: token);
    return BuyCoinsModel.fromJson(response);
  }
}
