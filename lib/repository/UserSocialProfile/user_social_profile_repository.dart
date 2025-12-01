import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/UserSocialProfileModel/user_social_profile_model.dart';

import '../../res/api_urls/api_urls.dart';

class UserSocialProfileRepository {
  final _apiService = NetworkApiServices();

  Future<UserSocialProfileModel> userSocialProfile(
      String token, String userId) async {
    final url = '${ApiUrls.userSocialProfileApi}/$userId';
    dynamic response = await _apiService.getApi(url, token: token);
    return UserSocialProfileModel.fromJson(response);
  }
}
