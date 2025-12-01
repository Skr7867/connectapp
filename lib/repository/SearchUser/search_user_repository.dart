import '../../data/network/network_api_services.dart';
import '../../models/AllUsers/search_users_model.dart';
import '../../res/api_urls/api_urls.dart';

class SearchUserRepository {
  Future<AllUsersModel> searchUsers(String token, String query) async {
    final url = "${ApiUrls.baseUrl}/connect/v1/api/user/find-user/$query";
    final response = await NetworkApiServices().getApi(url, token: token);

    return AllUsersModel.fromJson(response);
  }
}
