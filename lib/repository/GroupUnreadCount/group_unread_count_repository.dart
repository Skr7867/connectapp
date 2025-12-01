import 'package:connectapp/data/network/network_api_services.dart';
import '../../models/GroupUnreadCount/group_unread_count_model.dart';
import '../../res/api_urls/api_urls.dart';

class GroupUnreadCountRepository {
  final _apiService = NetworkApiServices();

  Future<List<GroupUnreadCountModel>> fetchGroupUnreadCount(
      String token) async {
    final response =
        await _apiService.getApi(ApiUrls.groupUnreadCountApi, token: token);

    return (response as List)
        .map((json) => GroupUnreadCountModel.fromJson(json))
        .toList();
  }
}
