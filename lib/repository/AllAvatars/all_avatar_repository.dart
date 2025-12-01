import 'package:connectapp/models/AllAvatar/all_avatar_model.dart';

import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class AllAvatarRepository {
  final _apiService = NetworkApiServices();

  Future<AllAvatarModel> allAvatar(
    String token,
  ) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.allAvatarApi, token: token);
    return AllAvatarModel.fromJson(response);
  }
}
