import 'package:connectapp/data/network/network_api_services.dart';
import '../../models/AllUsers/show_all_users_model.dart';
import '../../res/api_urls/api_urls.dart';

class AllUsersRepository {
  final _apiService = NetworkApiServices();

  Future<ShowAllUsersModel> allUsers(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.allUsersApi, token: token);
    return ShowAllUsersModel.fromJson(response);
  }
}
