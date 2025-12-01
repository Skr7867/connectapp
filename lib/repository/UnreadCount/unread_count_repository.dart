import 'package:connectapp/data/network/network_api_services.dart';
import '../../models/UnreadCount/unread_count_model.dart';
import '../../res/api_urls/api_urls.dart';

class UnreadCountRepository {
  final _apiService = NetworkApiServices();

  Future<List<UnreadCountModel>> fetchUnreadCount(String token) async {
    final response =
        await _apiService.getApi(ApiUrls.unreadCountApi, token: token);

    return (response as List)
        .map((json) => UnreadCountModel.fromJson(json))
        .toList();
  }
}
