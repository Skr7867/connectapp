import 'package:connectapp/data/network/network_api_services.dart';
import 'package:connectapp/models/Courses/all_courses_model.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';

class CourseRepository {
  final _apiService = NetworkApiServices();

  Future<Course> getCourseById(String courseId, String token) async {
    final response = await _apiService.getApi(
      '${ApiUrls.baseUrl}/courses/$courseId',
      token: token,
    );
    return Course.fromJson(response);
  }
}
