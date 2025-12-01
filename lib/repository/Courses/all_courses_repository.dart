import '../../data/network/network_api_services.dart';
import '../../models/Courses/all_courses_model.dart';
import '../../res/api_urls/api_urls.dart';

class AllCoursesRepository {
  final _apiService = NetworkApiServices();

  Future<List<Course>> getAllCourses(String token) async {
    dynamic response =
        await _apiService.getApi(ApiUrls.allCoursesApi, token: token);
    return (response as List<dynamic>)
        .map((json) => Course.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
