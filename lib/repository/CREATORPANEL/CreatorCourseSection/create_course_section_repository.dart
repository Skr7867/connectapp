import 'package:connectapp/data/network/network_api_services.dart';
import '../../../res/api_urls/api_urls.dart';

class CreateCourseSectionRepository {
  final _apiService = NetworkApiServices();

  Future<dynamic> createCourseSection(
      String token, String courseId, String title) async {
    final url = "${ApiUrls.createCourseSectionApi}/$courseId";
    final data = {'title': title};
    final response = await _apiService.postApi(data, url, token: token);
    return response;
  }
}
