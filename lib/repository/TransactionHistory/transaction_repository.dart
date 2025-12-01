import 'package:connectapp/data/network/network_api_services.dart';
import '../../models/Transaction/transaction_model.dart';
import '../../res/api_urls/api_urls.dart';

class TransactionRepository {
  final _apiService = NetworkApiServices();

  Future<UserTransactionModel> userTransaction(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.transactionApi, token: token);
    return UserTransactionModel.fromJson(response);
  }
}
