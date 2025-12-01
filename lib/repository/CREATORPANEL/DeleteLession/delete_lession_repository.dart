import 'package:connectapp/data/network/network_api_services.dart';
import '../../../res/api_urls/api_urls.dart';

class DeleteLessionRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> deleteLession(
      String token, String courseId, String sectionId, String lessionId) async {
    final url =
        "${ApiUrls.baseUrl}/connect/v1/api/creator/course/$courseId/section/$sectionId/delete-lesson/$lessionId";
    final response = await _apiService.deleteApi(url, token: token);
    return response;
  }
}
