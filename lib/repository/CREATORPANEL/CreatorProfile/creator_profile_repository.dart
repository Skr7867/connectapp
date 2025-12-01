import 'package:connectapp/data/network/network_api_services.dart';
import '../../../models/CREATORPANEL/Profile/creators_profile_model.dart';
import '../../../res/api_urls/api_urls.dart';

class CreatorProfileRepository {
  final _apiService = NetworkApiServices();

  Future<CreatorProfileModel> creatorProfile(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.creatorProfileApi, token: token);
    return CreatorProfileModel.fromJson(response);
  }
}
