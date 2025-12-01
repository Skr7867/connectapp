import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/AllUsersClips/all_user_clips_model.dart';
import '../../../res/api_urls/api_urls.dart';

class UserAllClipsRepository {
  final _apiService = NetworkApiServices();

  Future<AllUsersClipsModel> usersAllClips(String token, String userId) async {
    final url = '${ApiUrls.userAllClipsApi}/$userId';
    dynamic response = await _apiService.getApi(url, token: token);
    return AllUsersClipsModel.fromJson(response);
  }
}
