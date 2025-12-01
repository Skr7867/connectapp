import 'package:connectapp/data/network/network_api_services.dart';
import '../../models/AllFollowing/all_following_model.dart';
import '../../res/api_urls/api_urls.dart';

class AllFollowingRepository {
  final _apiService = NetworkApiServices();

  Future<AllFollowingModel> allFollowing(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.allFollowingApi, token: token);
    return AllFollowingModel.fromJson(response);
  }
}
