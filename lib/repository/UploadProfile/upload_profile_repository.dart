import '../../data/network/network_api_services.dart';
import '../../res/api_urls/api_urls.dart';

class UploadProfileRepository {
  final _apiServices = NetworkApiServices();

  Future<dynamic> uploadProfileApi(String token, dynamic data) async {
    return await _apiServices.patchApi(
      data,
      ApiUrls.uploadProfilePicApi,
      token: token,
      isFileUpload: true, // ⭐ VERY IMPORTANT
    );
  }
}
