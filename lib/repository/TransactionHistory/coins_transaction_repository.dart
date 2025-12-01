import 'package:connectapp/data/network/network_api_services.dart';
import '../../models/Transaction/user_coins_transaction_model.dart';
import '../../res/api_urls/api_urls.dart';

class CoinsTransactionRepository {
  final _apiService = NetworkApiServices();

  Future<UserCoinsTransactionModel> userCoinsTransaction(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.coinsTransactionApi, token: token);
    return UserCoinsTransactionModel.fromJson(response);
  }
}
