import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/RepostedClips/repsoted_clips_model.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';

class RepostedClipsRepository {
  final _apiService = NetworkApiServices();

  Future<RepostedClipsModel> repostedClips(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.repostedClipsApi, token: token);
    return RepostedClipsModel.fromJson(response);
  }
}
