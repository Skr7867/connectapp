import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/userProfile/user_profile_model.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';

import '../../models/UserProfile/user_profile_media_list_model.dart';

class GetUserProfileRepository {
  final _apiService = NetworkApiServices();

  Future<UserProfileModel> userProfileData(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.userProfileApi, token: token);
    return UserProfileModel.fromJson(response);
  }

  Future<UserProfileMediaListModel> userMediaListData(
      String token, String chatType, String userId) async {
    dynamic response = await _apiService.getApi(
        "${ApiUrls.baseUrl}/connect/v1/api/user/get-chat-media/$chatType/$userId",
        token: token);
    return UserProfileMediaListModel.fromJson(response);
  }
}
