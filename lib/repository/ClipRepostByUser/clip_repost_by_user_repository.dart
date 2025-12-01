import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/ClipRepostByUser/clip_repost_by_user_model.dart';
import '../../../res/api_urls/api_urls.dart';

class ClipRepostByUserRepository {
  final _apiService = NetworkApiServices();

  Future<ClipRepostByUser> clipRepostByUser(String token, String clipId) async {
    final url = '${ApiUrls.clipRepostedByUser}/$clipId';
    dynamic response = await _apiService.getApi(url, token: token);
    return ClipRepostByUser.fromJson(response);
  }
}
