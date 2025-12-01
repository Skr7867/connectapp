import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/UserAvatar/user_avatar_model.dart';

import '../../res/api_urls/api_urls.dart';

class UserAvatarRepository {
  final _apiService = NetworkApiServices();

  Future<UserAvatarModel> userAvatar(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.userAvatarApi, token: token);
    return UserAvatarModel.fromJson(response);
  }
}
