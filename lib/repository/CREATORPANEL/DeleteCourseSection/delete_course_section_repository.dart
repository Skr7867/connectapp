import 'package:connectapp/data/network/network_api_services.dart';
import '../../../res/api_urls/api_urls.dart';

class DeleteCourseSectionRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> deleteCourseSection(
      String token, String courseId, String sectionId) async {
    final url =
        "${ApiUrls.baseUrl}/connect/v1/api/creator/course/$courseId/section/$sectionId/delete";
    final response = await _apiService.deleteApi(url, token: token);
    return response;
  }
}
