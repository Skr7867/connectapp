import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/Notification/notification_module.dart';

import '../../res/api_urls/api_urls.dart';

class AllNotificationRepository {
  final _apiService = NetworkApiServices();

  Future<NotificationModel> allNotification(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.notificationApi, token: token);
    return NotificationModel.fromJson(response);
  }
}
