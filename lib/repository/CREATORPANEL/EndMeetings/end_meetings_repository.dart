import '../../../data/network/network_api_services.dart';
import '../../../res/api_urls/api_urls.dart';

class EndMeetingsRepository {
  final _apiServices = NetworkApiServices();

  Future<dynamic> endMeetings(
    String spaceId,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    return await _apiServices.patchApi(
      data,
      ApiUrls.endMeetingsApi,
      token: token,
    );
  }
}
