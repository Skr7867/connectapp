import '../../../data/network/network_api_services.dart';
import '../../../res/api_urls/api_urls.dart';

class StartMeetingsRepository {
  final _apiServices = NetworkApiServices();

  Future<dynamic> startMeetings(
    String spaceId,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    return await _apiServices.patchApi(
      data,
      ApiUrls.startMeetingsApi,
      token: token,
    );
  }
}
