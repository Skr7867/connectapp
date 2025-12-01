import '../../data/network/network_api_services.dart';
import '../../models/PopularCourses/popular_courses_model.dart';
import '../../res/api_urls/api_urls.dart';

class PopularCoursesRepository {
  final _apiService = NetworkApiServices();

  Future<PopularCourseModel> getPopularCourses(String token, int pageNo) async {
    final url = '${ApiUrls.popularCourseApi}?page=$pageNo';
    final response = await _apiService.getApi(url, token: token);
    return PopularCourseModel.fromJson(response);
  }
}
