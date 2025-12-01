import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/Leaderboard/leaderboard_response_model.dart';

import '../../res/api_urls/api_urls.dart';

class LeaderboardRepository {
  final _apiService = NetworkApiServices();

  Future<LeaderboardResponseModel> userLeaderboard(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.leaderBoardApi, token: token);
    return LeaderboardResponseModel.fromJson(response);
  }
}
