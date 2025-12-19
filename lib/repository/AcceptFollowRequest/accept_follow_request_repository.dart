import 'package:connectapp/models/PendingFollowRequestModel/pending_follow_request_model.dart';
import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class AcceptFollowRequestRepository {
  final _apiService = NetworkApiServices();

  // Fetch pending requests
  Future<PendingFollowRequestModel> pendingFollowrequest(String token) async {
    dynamic response = await _apiService.getApi(
      ApiUrls.pendingFollowRequestApi,
      token: token,
    );
    return PendingFollowRequestModel.fromJson(response);
  }

  // ✅ FIXED: Accept / Reject follow request
  Future<dynamic> respondFollowRequest({
    required String token,
    required String action, // accept | reject
    required String fromUserId,
  }) async {
    final Map<String, dynamic> data = {
      "action": action,
      "fromUserId": fromUserId,
    };

    // ✅ PASS MAP DIRECTLY (NOT toString)
    // ✅ ORDER MATCHES postApi(data, url)
    return await _apiService.postApi(
      data, // ✅ BODY
      ApiUrls.acceptFollowRequestApi, // ✅ URL
      token: token,
    );
  }
}
