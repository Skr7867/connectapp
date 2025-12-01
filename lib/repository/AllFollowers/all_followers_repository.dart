import 'package:connectapp/data/network/network_api_services.dart';
import '../../models/AllFollowers/all_followers_model.dart';
import '../../res/api_urls/api_urls.dart';

class AllFollowersRepository {
  final _apiService = NetworkApiServices();

  Future<AllFollowersModel> allFollowers(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.allFollowersApi, token: token);
    return AllFollowersModel.fromJson(response);
  }
}
