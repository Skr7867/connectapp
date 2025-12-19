import 'package:connectapp/models/PendingFollowRequestModel/pending_follow_request_model.dart';

import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class PendingFollowRequestRepository {
  final _apiService = NetworkApiServices();

  Future<PendingFollowRequestModel> pendingFollowrequest(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.pendingFollowRequestApi, token: token);
    return PendingFollowRequestModel.fromJson(response);
  }
}
